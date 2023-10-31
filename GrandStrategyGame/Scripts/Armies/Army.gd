class_name Army
extends Node2D


signal destroyed(Army)

var _army_size: ArmySize
var owner_country: Country = null : set = set_owner_country

var _key: String

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
func setup(army_size: int) -> void:
	_army_size = ArmySize.new(army_size, 10)
	_army_size.connect(
			"size_changed", Callable(self, "_on_army_size_changed")
	)
	_army_size.connect(
			"became_too_small", Callable(self, "destroy")
	)
	_update_troop_count_label()


func key() -> String:
	return _key


func destroy() -> void:
	destroyed.emit(self)
	queue_free()


func current_size() -> int:
	return _army_size.current_size()


func set_owner_country(value: Country) -> void:
	owner_country = value
	($ColorRect as ColorRect).color = owner_country.color


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
	troop_count_label.text = str(_army_size.current_size())
