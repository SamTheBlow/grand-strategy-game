class_name Army
extends Node2D


signal destroyed(army: Army)

@export var battle: Battle

var game: Game

var id: int

var army_size: ArmySize
var _province: Province
var _owner_country := Country.new()


# Lets the game know this army can still perform actions
var is_active: bool = true : set = set_active

var original_position: Vector2 = position
var target_position: Vector2 = position
var animation_is_playing: bool = false
var animation_speed: float = 1.0


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


func _on_army_size_changed() -> void:
	_update_troop_count_label()


func destroy() -> void:
	destroyed.emit(self)
	queue_free()


func province() -> Province:
	return _province


func move_to_province(destination: Province) -> void:
	if not animation_is_playing:
		global_position = destination.position_army_host
	
	if _province:
		_province.armies.remove_child(self)
	_province = destination
	_province.armies.add_child(self)
	
	resolve_battles(game.world.armies.armies_in_province(_province))


func owner_country() -> Country:
	return _owner_country


func set_owner_country(value: Country) -> void:
	_owner_country = value
	($ColorRect as ColorRect).color = _owner_country.color


func set_active(value: bool) -> void:
	is_active = value
	if is_active:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		z_index = 1
	else:
		z_index = 5


func play_movement_to(destination_province: Province) -> void:
	self.is_active = false
	animation_is_playing = true
	original_position = _province.position_army_host
	target_position = destination_province.position_army_host
	global_position = original_position


func gray_out() -> void:
	var v: float = 0.5
	modulate = Color(v, v, v, 1.0)


## Stops all animations and sets the army back to active.
func refresh_visuals() -> void:
	stop_animations()
	self.is_active = true


func stop_animations() -> void:
	if animation_is_playing:
		animation_is_playing = false
		position = target_position
		gray_out()


func resolve_battles(armies: Array[Army]) -> void:
	for other_army in armies:
		if other_army.owner_country() != owner_country():
			fight(other_army)


func fight(army: Army) -> void:
	battle.attacking_army = self
	battle.defending_army = army
	battle.apply(game)


func can_move_to(destination: Province) -> bool:
	return destination.is_linked_to(_province)


static func money_cost(troop_count: int, rules: GameRules) -> int:
	return ceili(troop_count * rules.recruitment_money_per_unit)


static func population_cost(troop_count: int, rules: GameRules) -> int:
	return ceili(troop_count * rules.recruitment_population_per_unit)


func _update_troop_count_label() -> void:
	var troop_count_label := $ColorRect/TroopCount as Label
	troop_count_label.text = str(army_size.current_size())


static func quick_setup(
		game_: Game,
		id_: int,
		army_size_: int,
		owner_country_: Country,
		province_: Province
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
	
	game_.world.armies.add_army(army)
	army.move_to_province(province_)
	return army
