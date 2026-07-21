class_name CameraInertia
extends Node

@export var _camera: CustomCamera2D

## Set this to false if you don't want any inertia.
@export var is_enabled: bool = true

## Determines how quickly the inertia decays.
## A value of 0 means it stops instantly.
## A value of 1 means it doesn't decay at all.
@export var decay_rate: float = 0.9983

var _velocity := Vector2.ZERO

# Keeps track of where the mouse has been going
# so that we can calculate a weighted average for smoother inertia
var _previous_mouse_positions: Array[Vector2] = []
var _previous_mouse_timestamps: Array[int] = []
var _number_of_positions: int = 60


func _process(_delta: float) -> void:
	# Note down the current mouse position with timestamp
	# Get rid of older ones to save memory
	_previous_mouse_positions.append(get_viewport().get_mouse_position())
	_previous_mouse_timestamps.append(Engine.get_process_frames())
	while _previous_mouse_positions.size() > _number_of_positions:
		_previous_mouse_positions.pop_front()
		_previous_mouse_timestamps.pop_front()

	if not is_enabled or _velocity.is_zero_approx():
		_velocity = Vector2.ZERO

	if _velocity != Vector2.ZERO:
		# Move camera
		_camera.move_to(_camera.position + _velocity / _camera.zoom)
		# Reduce velocity
		_velocity *= decay_rate


# Example:
# Say the positions are [(10,16), (12,20), (13,23)],
# the timestamps are [1, 2, 3], and the current mouse position is (13,24).
# Then the total_position_delta is (3,8)+(1,4)+(0,1)=(4,12),
# the total_time_delta is 3+2+1=6, and so the output is (0.67, 2).
#
## Returns the weighted average of the previous mouse positions
func _mouse_motion() -> Vector2:
	# Edge case where we haven't sampled enough positions yet
	if _previous_mouse_positions.size() < _number_of_positions:
		return Vector2.ZERO

	var current_mouse_position: Vector2 = get_viewport().get_mouse_position()
	var current_timestamp: int = Engine.get_process_frames()

	var total_position_delta := Vector2.ZERO
	var total_time_delta: float = 0.0

	# Get the sums
	for i: int in _previous_mouse_positions.size():
		total_position_delta += (
			current_mouse_position - _previous_mouse_positions[i]
		)
		total_time_delta += (
			current_timestamp - _previous_mouse_timestamps[i]
		)

	# Prevent division by zero
	if total_time_delta == 0:
		return Vector2.ZERO

	return total_position_delta / total_time_delta


# Disables inertia the moment camera drag begins
func _on_camera_drag_started() -> void:
	_velocity = Vector2.ZERO


# Enables inertia the moment camera drag ends
func _on_camera_drag_ended() -> void:
	_velocity = -_mouse_motion()
