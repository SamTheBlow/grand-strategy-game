class_name ArmyMovementAnimation2D
extends Node
## Responsible for animating 2D visuals for an [Army] when it moves.


signal is_playing_changed(is_playing: bool)

@export var _army_visuals: Node2D

@export var animation_speed: float = 1.0

var _is_playing: bool = false:
	set(value):
		if _is_playing == value:
			return
		_is_playing = value
		if _is_playing:
			_army_visuals.global_position = original_global_position
		else:
			_army_visuals.global_position = target_global_position
		is_playing_changed.emit(_is_playing)

# NOTE: We need to use global position here because it's possible for the army's
# parent to change while the animation is playing. When that happens, relative
# values stop working because they're relative to the former parent node.
var original_global_position: Vector2
var target_global_position: Vector2


func _process(delta: float) -> void:
	if not _is_playing:
		return
	
	var new_position: Vector2 = (
			_army_visuals.global_position
			+ (target_global_position - original_global_position)
			* animation_speed * delta
	)
	if (
			new_position.distance_squared_to(original_global_position)
			>=
			target_global_position.distance_squared_to(original_global_position)
	):
		stop()
	else:
		_army_visuals.global_position = new_position


## Plays an animation where the army visually moves to the target position.
func play() -> void:
	_is_playing = true


## The army's visuals will immediately move to the animation's end position.
func stop() -> void:
	_is_playing = false


func is_playing() -> bool:
	return _is_playing
