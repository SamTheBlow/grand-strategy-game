class_name Army
extends Node2D
## Class reponsible for an army's data, behavior, and visuals.
## An army represents any entity on the world map.
## It is usually under the control of a [Country], and
## it is usually located on a [Province].
## Note that it is currently called "army", but in truth,
## this class actually represents any entity, not just military ones.


## Emitted when this army believes it has been destroyed.
## At the time it's emitted, this node already queued itself for deletion.
signal destroyed(army: Army)

# TODO bad code. all armies should have the same battle object
## The [Battle] resource that will define the outcome of a battle.
@export var battle: Battle

## A reference to the [Game] this army is part of.
## It must be set immediately when this army is created.
var game: Game:
	set(value):
		if game:
			game.turn.turn_changed.disconnect(_on_new_turn)
			game.turn.player_changed.disconnect(_on_player_turn)
		game = value
		game.turn.turn_changed.connect(_on_new_turn)
		game.turn.player_changed.connect(_on_player_turn)

## In each game, all armies must have their own unique id.
## This is for the purposes of saving and loading, and also for
## the purposes of sending data about this army to network clients.
var id: int

# Variables for the movement animation
var original_position: Vector2 = position
var target_position: Vector2 = position
var animation_is_playing: bool = false
var animation_speed: float = 1.0

## Provides information on this army's size.
## This must be set immediately when this army is created.
var army_size: ArmySize

# More things that need to be set immediately when this army is created.
# Feel free to change these at any time during the game.
var _province: Province
var _owner_country := Country.new()

# For now, there's a hard limit of 1 movement per turn,
# but in the future we should make it possible to change the limit
var _movements_made: int = 0:
	set(value):
		_movements_made = value
		_refresh_visuals()


func _process(delta: float) -> void:
	# Play the movement animation, if applicable
	if animation_is_playing:
		var new_position: Vector2 = (
				global_position
				+ (target_position - original_position)
				* animation_speed * delta
		)
		if (
				new_position.distance_squared_to(original_position)
				>= target_position.distance_squared_to(original_position)
		):
			stop_animations()
		else:
			global_position = new_position


## Utility function that does all the setup work.
## It is recommended to use this when creating a new army.
static func quick_setup(
		game_: Game,
		id_: int,
		army_size_: int,
		owner_country_: Country,
		province_: Province,
		movements_made_: int = 0,
) -> Army:
	var minimum_army_size: int = game_.rules.minimum_army_size
	if army_size_ < minimum_army_size:
		return null
	
	var army := game_.army_scene.instantiate() as Army
	army.game = game_
	army.id = id_
	army.name = str(army.id)
	
	army.army_size = ArmySize.new(army_size_, minimum_army_size)
	army.army_size.size_changed.connect(army._on_army_size_changed)
	army.army_size.became_too_small.connect(army.destroy)
	army._update_troop_count_label()
	
	army.set_owner_country(owner_country_)
	army._movements_made = movements_made_
	
	game_.world.armies.add_army(army)
	army.teleport_to_province(province_)
	return army


func destroy() -> void:
	destroyed.emit(self)
	queue_free()


func province() -> Province:
	return _province


## If true, the army can still make a movement.
## Once an army moves, it can't move again on the same turn.
func is_able_to_move() -> bool:
	return _movements_made == 0


## If true, the army is allowed to move to the given province.
## An army can only move to an adjacent province.
## This returns true regardless of if the army is able to move at all.
func can_move_to(destination: Province) -> bool:
	return destination.is_linked_to(_province)


## Moves this army to the given destination province. No animation will play.
## To play an animation, consider using play_movement_animation().[br]
## [br]
## Calling this function will increase this army's number of movements made.
## The army may have a hard limit on how many movements it can make.
## Once that limit is reached, this function has no effect.[br]
## If you want to move an army without affecting its movement count,
## consider using teleport_to_province() instead.
func move_to_province(destination: Province) -> void:
	if not is_able_to_move():
		return
	
	_movements_made += 1
	teleport_to_province(destination)


## Moves this army to the given destination province. No animation will play,
## and the army's movement count will be unaffected.
## The movement will be performed even if the army is unable to move.
func teleport_to_province(destination: Province) -> void:
	if _province:
		_province.army_stack.remove_child(self)
	_province = destination
	_province.army_stack.add_child(self)
	
	resolve_battles(game.world.armies.armies_in_province(_province))


func owner_country() -> Country:
	return _owner_country


# TODO make the owner_country variable public and put this in its setter
## Use this to change what [Country] has control over this army.
func set_owner_country(value: Country) -> void:
	_owner_country = value
	($ColorRect as ColorRect).color = _owner_country.color


## Plays an animation where the army visually moves to given province.
## Note that this does not actually move the army to that province!
func play_movement_to(destination_province: Province) -> void:
	animation_is_playing = true
	original_position = _province.position_army_host
	target_position = destination_province.position_army_host
	global_position = original_position


## Forcefully, prematurely ends the movement animation.
## The army's visuals will immediately move to the animation's end position.
func stop_animations() -> void:
	if animation_is_playing:
		animation_is_playing = false
		position = target_position
		_refresh_visuals()


## Engages this army into a battle with all armies in given list
## that are not under control of the same [Country] as this one.
func resolve_battles(armies: Array[Army]) -> void:
	for other_army in armies:
		if other_army.owner_country() != owner_country():
			fight(other_army)


## Starts a battle against given [Army],
## where this army is the attacker and the input army is the defender.
func fight(army: Army) -> void:
	battle.attacking_army = self
	battle.defending_army = army
	battle.apply(game)


## Returns the number of times this army has moved.
## This number may reset, for example, when a new turn begins.
func movements_made() -> int:
	return _movements_made


## How much in-game money it would cost to recruit given troop count.
static func money_cost(troop_count: int, rules: GameRules) -> int:
	return ceili(troop_count * rules.recruitment_money_per_unit)


## How much [Population] it would cost to recruit given troop count.
static func population_cost(troop_count: int, rules: GameRules) -> int:
	return ceili(troop_count * rules.recruitment_population_per_unit)


## Darkens the army sprite if the army cannot perform any action.
func _refresh_visuals() -> void:
	if (
			is_able_to_move()
			or (game.turn.playing_player().playing_country != _owner_country)
			or animation_is_playing
	):
		modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		var v: float = 0.5
		modulate = Color(v, v, v, 1.0)


func _update_troop_count_label() -> void:
	var troop_count_label := $ColorRect/TroopCount as Label
	troop_count_label.text = str(army_size.current_size())


func _on_new_turn(_turn_number: int) -> void:
	_movements_made = 0


func _on_player_turn(_player: GamePlayer) -> void:
	_refresh_visuals()


func _on_army_size_changed() -> void:
	_update_troop_count_label()
