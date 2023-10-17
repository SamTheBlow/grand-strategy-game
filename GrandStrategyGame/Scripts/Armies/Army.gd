class_name Army
extends Node2D


var owner_country: Country = null : set = set_owner_country
var troop_count: int = 1 : set = set_troop_count

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


func key() -> String:
	return _key


func set_owner_country(value: Country) -> void:
	owner_country = value
	($ColorRect as ColorRect).color = owner_country.color


func set_troop_count(value: int) -> void:
	troop_count = value
	($ColorRect/TroopCount as Label).text = str(troop_count)


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
