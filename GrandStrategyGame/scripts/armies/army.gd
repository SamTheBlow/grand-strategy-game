class_name Army
extends Node2D


signal destroyed(Army)

var id: int

var army_size := ArmySize.new()
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
				position
				+ (target_position - original_position)
				* animation_speed * delta
		)
		if (
				new_position.distance_squared_to(original_position)
				>= target_position.distance_squared_to(original_position)
		):
			stop_animations()
		else:
			position = new_position


func _on_army_size_changed() -> void:
	_update_troop_count_label()


## Only call once during setup. Make sure the scene is fully loaded first.
## army_size must be greater or equal to 10
func setup(army_size_: int) -> void:
	army_size = ArmySize.new(army_size_, 10)
	army_size.connect(
			"size_changed", Callable(self, "_on_army_size_changed")
	)
	army_size.connect(
			"became_too_small", Callable(self, "destroy")
	)
	_update_troop_count_label()


func destroy() -> void:
	destroyed.emit(self)
	queue_free()


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


func play_movement_to(source: Vector2, destination: Vector2) -> void:
	self.is_active = false
	animation_is_playing = true
	position = source
	original_position = source
	target_position = destination


func gray_out() -> void:
	var v: float = 0.5
	modulate = Color(v, v, v, 1.0)


func stop_animations() -> void:
	if animation_is_playing:
		animation_is_playing = false
		position = target_position
		gray_out()


func _update_troop_count_label() -> void:
	var troop_count_label := $ColorRect/TroopCount as Label
	troop_count_label.text = str(army_size.current_size())


static func from_JSON(json_data: Dictionary, game_state: GameState) -> Army:
	var army := preload("res://scenes/army.tscn").instantiate() as Army
	army.id = json_data["id"]
	army.setup(json_data["army_size"])
	army.set_owner_country(game_state.countries.country_from_id(
			json_data["owner_country_id"]
	))
	army.name = str(army.id)
	return army


func as_JSON() -> Dictionary:
	return {
		"id": id,
		"army_size": army_size.as_JSON(),
		"owner_country_id": _owner_country.id,
	}
