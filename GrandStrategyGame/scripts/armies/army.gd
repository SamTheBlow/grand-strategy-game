class_name Army
extends Node2D


signal destroyed(army: Army)

@export var battle: Battle

var game: Game:
	set(value):
		if game:
			game.turn.turn_changed.disconnect(_on_new_turn)
			game.turn.player_changed.disconnect(_on_player_turn)
		game = value
		game.turn.turn_changed.connect(_on_new_turn)
		game.turn.player_changed.connect(_on_player_turn)

var id: int

# Variables for the movement animation
var original_position: Vector2 = position
var target_position: Vector2 = position
var animation_is_playing: bool = false
var animation_speed: float = 1.0

var army_size: ArmySize
var _province: Province
var _owner_country := Country.new()

# For now, there's a hard limit of 1 movement per turn,
# but in the future we should make it possible to change the limit
var _movements_made: int = 0:
	set(value):
		_movements_made = value
		_refresh_visuals()


func _process(delta: float) -> void:
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


func stop_animations() -> void:
	if animation_is_playing:
		animation_is_playing = false
		position = target_position
		_refresh_visuals()


func resolve_battles(armies: Array[Army]) -> void:
	for other_army in armies:
		if other_army.owner_country() != owner_country():
			fight(other_army)


func fight(army: Army) -> void:
	battle.attacking_army = self
	battle.defending_army = army
	battle.apply(game)


## Returns the number of times this army has moved.
## This number may reset, for example, when a new turn begins.
func movements_made() -> int:
	return _movements_made


static func money_cost(troop_count: int, rules: GameRules) -> int:
	return ceili(troop_count * rules.recruitment_money_per_unit)


static func population_cost(troop_count: int, rules: GameRules) -> int:
	return ceili(troop_count * rules.recruitment_population_per_unit)


# Darkens the army sprite if the army cannot perform any action
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


func _on_player_turn(_player: Player) -> void:
	_refresh_visuals()


func _on_army_size_changed() -> void:
	_update_troop_count_label()
