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
signal province_changed(this_army: Army, province: Province)
## Emitted only when using [method Army.move_to_province].
## Teleportation does not trigger this signal.
## Emitted after province_changed.
signal moved_to_province(province: Province)
signal movements_made_changed(movements_made: int)

## Emitted when this army believes it has been destroyed.
## This is used to ask the game to remove the army from the game.
signal destroyed(this_army: Army)
## Emitted right after this army is actually removed from the game.
## This is used to ask the game to remove this army's visuals.
signal removed()

## A reference to the [Game] this army is part of.
## Must initialize when the army is created.
var game: Game:
	set(value):
		if game:
			game.turn.player_changed.disconnect(_on_player_turn_changed)
		game = value
		game.turn.player_changed.connect(_on_player_turn_changed)

## In each game, all armies must have their own unique id.
## This is for the purposes of saving and loading, and also for
## the purposes of sending data about this army to network clients.
var id: int

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

## The [Province] in which this army is located. Currently must not be null.
## Must initialize when the army is created.
var _province: Province:
	set(value):
		if value == null:
			push_warning("Tried to set an army's province to null!")
			return
		
		_province = value
		province_changed.emit(self, _province)

## The number of movements made by this army.
## Currently, there's a limit of 1 movement per turn
## and this property resets to 0 on each turn.
var _movements_made: int = 0:
	set(value):
		_movements_made = value
		movements_made_changed.emit(_movements_made)


## Utility function that does all the setup work.
## Automatically adds the army to the game and moves it to given [Province].
## It is recommended to use this when creating a new army.
static func quick_setup(
		game_: Game,
		id_: int,
		army_size_: int,
		owner_country_: Country,
		province_: Province,
		movements_made_: int = 0,
) -> Army:
	var minimum_army_size: int = game_.rules.minimum_army_size.value
	if army_size_ < minimum_army_size:
		push_error(
				"Tried to create an army, "
				+ "but its size is smaller than the minimum allowed."
		)
		return null
	
	var army := Army.new()
	army.game = game_
	army.id = id_
	army.army_size = ArmySize.new(army_size_, minimum_army_size)
	army.owner_country = owner_country_
	army._movements_made = movements_made_
	
	game_.world.armies.add_army(army)
	army.add_visuals()
	army.teleport_to_province(province_)
	return army


func add_visuals() -> void:
	var visuals := game.army_scene.instantiate() as ArmyVisuals2D
	visuals.army = self


func remove_visuals() -> void:
	removed.emit()


func destroy() -> void:
	destroyed.emit(self)


func province() -> Province:
	return _province


## If true, the army can still make a movement.
## Once an army moves, it can't move again on the same turn.
func is_able_to_move() -> bool:
	return _movements_made == 0


## If true, the army is allowed to move to the given province.
## An army can only move to an adjacent province. And when moving into
## foreign territory, the army's owner must be allowed to enter.
## This returns true regardless of if the army is able to move at all.
func can_move_to(destination: Province) -> bool:
	return (
			destination.is_linked_to(_province)
			and owner_country.can_move_into_country(destination.owner_country)
	)


## Moves this army to the given destination province.[br]
## [br]
## Calling this function will increase this army's number of movements made.
## The army may have a hard limit on how many movements it can make.
## Once that limit is reached, this function has no effect.[br]
## If you want to move an army without affecting its movement count,
## consider using teleport_to_province() instead.
func move_to_province(destination: Province) -> void:
	if not is_able_to_move():
		return
	if not can_move_to(destination):
		push_error("Tried to move an army to a province it can't move to.")
		return
	
	_movements_made += 1
	_province = destination
	moved_to_province.emit(destination)


## Moves this army to the given destination province.
## No animation will play, and the army's movement count will be unaffected.
## The movement will be performed even if the army is unable to move.
func teleport_to_province(destination: Province) -> void:
	_province = destination


## Returns the number of times this army has moved.
## This number may reset, for example, when a new turn begins.
func movements_made() -> int:
	return _movements_made


## Artificially increases the army's number of movements made
## such that it is no longer able to move, if applicable.
func exhaust() -> void:
	# (In the future it won't be that simple)
	_movements_made = 1


## How much in-game money it would cost to recruit given troop count.
static func money_cost(troop_count: int, rules: GameRules) -> int:
	return (
			ResourceCost.new(rules.recruitment_money_per_unit.value)
			.cost_fori(troop_count)
	)


## How much [Population] it would cost to recruit given troop count.
static func population_cost(troop_count: int, rules: GameRules) -> int:
	return (
			ResourceCost.new(rules.recruitment_population_per_unit.value)
			.cost_fori(troop_count)
	)


func _on_player_turn_changed(player: GamePlayer) -> void:
	if player.playing_country == owner_country:
		_movements_made = 0


func _on_size_changed(new_size: int) -> void:
	size_changed.emit(new_size)
