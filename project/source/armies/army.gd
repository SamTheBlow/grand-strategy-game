class_name Army
## Represents any entity on the world map.
## This class is responsible for its data and behavior.
## It is usually under the control of a [Country], and
## it is usually located on a [Province].
## Note that it is currently called "army", but in truth,
## this class actually represents any entity, not just military ones.
##
## See also: [ArmyVisuals2D]

signal size_changed(size: int)
signal allegiance_changed(country: Country)
## Always emitted when the province changes.
signal province_changed(this_army: Army)
## Emitted only when using [method Army.move_to_province].
## Teleportation does not trigger this signal.
## Emitted after province_changed.
signal moved_to_province(province: Province)
signal movements_made_changed(movements_made: int)

## Emitted when this army believes it has been destroyed.
## This is used to ask the game to remove the army from the game.
signal destroyed(this_army: Army)

## Unique identifier. Useful for saving/loading, networking, etc.
var id: int = -1

## Provides information on this army's size. Currently must not be null.
## Must initialize when the army is created.
var army_size: ArmySize:
	set(value):
		if army_size:
			army_size.size_changed.disconnect(_on_size_changed)
			army_size.became_too_small.disconnect(destroy)
		army_size = value
		army_size.size_changed.connect(_on_size_changed)
		army_size.became_too_small.connect(destroy)

## The [Country] in control of this army.
## This must not be null! If you want an army to be unaligned,
## create a new [Country] to represent unaligned armies.
## Must initialize when the army is created.
var owner_country: Country:
	set(value):
		if value == null:
			push_warning("Tried to set an army's owner country to null!")
			return

		owner_country = value
		allegiance_changed.emit(owner_country)

## The province in which this army is located.
var _province_id: int = -1:
	set(value):
		if _province_id == value:
			return
		_province_id = value
		province_changed.emit(self)

## The number of movements made by this army.
## Currently, there's a limit of 1 movement per turn
## and this property resets to 0 on each turn.
var _movements_made: int = 0:
	set(value):
		_movements_made = value
		movements_made_changed.emit(_movements_made)


## Utility function that does all the setup work.
## Automatically adds the army to the game.
## It is recommended to use this when creating a new army.
## May return null if the army could not be created.
## Use -1 for the id if you don't want to provide a specific one.
static func quick_setup(
		game: Game,
		army_size_: int,
		owner_country_: Country,
		province_id_: int,
		id_: int = -1,
		movements_made_: int = 0,
) -> Army:
	var minimum_army_size: int = game.rules.minimum_army_size.value
	if army_size_ < minimum_army_size:
		push_error(
				"Tried to create an army, "
				+ "but its size is smaller than the minimum allowed."
		)
		return null

	var army := Army.new()
	army.id = id_
	army.army_size = ArmySize.new(army_size_, minimum_army_size)
	army.owner_country = owner_country_
	army._province_id = province_id_
	army._movements_made = movements_made_

	game.turn.player_changed.connect(army._on_player_turn_changed)
	game.world.armies.add(army)
	return army


func destroy() -> void:
	destroyed.emit(self)


func province_id() -> int:
	return _province_id


## Returns null if there is no province with this army's province id.
func province(provinces: Provinces) -> Province:
	return provinces.province_from_id(_province_id)


## If true, the army can still make a movement.
## Once an army moves, it can't move again on the same turn.
func is_able_to_move() -> bool:
	return _movements_made == 0


## If true, the army is allowed to move to the given province.
## An army can only move to an adjacent province. And when moving into
## foreign territory, the army's owner must be allowed to enter.
## This returns true regardless of if the army is able to move at all.
func can_move_to(provinces: Provinces, destination_province_id: int) -> bool:
	var source_province: Province = provinces.province_from_id(_province_id)
	if source_province == null:
		return false
	var destination_province: Province = (
			provinces.province_from_id(destination_province_id)
	)
	if destination_province == null:
		return false
	return (
			source_province.is_linked_to(destination_province_id)
			and owner_country.can_move_into_country(
					destination_province.owner_country
			)
	)


## Moves this army to the given destination province.[br]
## [br]
## Calling this function will increase this army's number of movements made.
## The army may have a hard limit on how many movements it can make.
## Once that limit is reached, this function has no effect.[br]
## If you want to move an army without affecting its movement count,
## consider using teleport_to_province() instead.
func move_to_province(
		provinces: Provinces, destination_province_id: int
) -> void:
	if not is_able_to_move():
		return
	if not can_move_to(provinces, destination_province_id):
		push_error("Tried to move an army to a province it can't move to.")
		return

	_movements_made += 1
	_province_id = destination_province_id
	# We don't check for null because it's already done in can_move_to
	moved_to_province.emit(provinces.province_from_id(destination_province_id))


## Moves this army to given destination province.
## Always succeeds, with no side effects. Does not emit any signal.
func teleport_to_province(destination_province_id: int) -> void:
	_province_id = destination_province_id


## Returns the number of times this army has moved.
## This number may reset, for example, when a new turn begins.
func movements_made() -> int:
	return _movements_made


## Artificially increases the army's number of movements made
## such that it is no longer able to move, if applicable.
func exhaust() -> void:
	# (In the future it won't be that simple)
	_movements_made = 1


## Returns true if this army is currently trespassing in a foreign province.
func is_trespassing(provinces: Provinces) -> bool:
	var current_province: Province = province(provinces)
	if current_province == null:
		return false
	return (
			owner_country.relationships
			.with_country(current_province.owner_country).is_trespassing()
	)


## How much in-game money it would cost to recruit given troop count.
static func money_cost(troop_count: int, rules: GameRules) -> int:
	return ResourceCost.new(
			"Money", rules.recruitment_money_per_unit.value
	).cost_fori(troop_count)


## How much [Population] it would cost to recruit given troop count.
static func population_cost(troop_count: int, rules: GameRules) -> int:
	return ResourceCost.new(
			"Population", rules.recruitment_population_per_unit.value
	).cost_fori(troop_count)


func _on_player_turn_changed(player: GamePlayer) -> void:
	if player.playing_country == owner_country:
		_movements_made = 0


func _on_size_changed(new_size: int) -> void:
	size_changed.emit(new_size)
