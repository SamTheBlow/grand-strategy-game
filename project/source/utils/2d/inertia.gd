class_name Inertia
extends Node
## Tracks mouse motion and provides a decaying velocity.
##
## Emits [signal velocity_processed] at a fast rate with the current velocity.
## Connect that signal to whatever node needs it and apply the velocity there.
##
## Use [method start] to generate velocity and [method stop] to reset velocity.

## Emits at a fast rate, only when the velocity is non-zero.
signal velocity_processed(velocity: Vector2)

## The maximum number of mouse positions to keep in memory.
const _MAX_MOUSE_POSITIONS: int = 20

## If false, velocity is always zero.
@export var is_enabled: bool = true

## Determines how quickly the velocity decays.
## A value of 0 means it stops instantly.
## A value of 1 means it doesn't decay at all.
@export var decay_rate: float = 0.97

var _velocity := Vector2.ZERO

# Keeps track of where the mouse has been going
# so that we can calculate a weighted average for smoother inertia.
var _previous_mouse_positions: PackedVector2Array = []
var _previous_mouse_timestamps: PackedInt64Array = []


func _process(delta: float) -> void:
	# Note down the current mouse position with timestamp
	# Get rid of older ones to save memory
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_previous_mouse_positions.append(get_viewport().get_mouse_position())
		_previous_mouse_timestamps.append(Engine.get_process_frames())
		while _previous_mouse_positions.size() > _MAX_MOUSE_POSITIONS:
			_previous_mouse_positions.remove_at(0)
			_previous_mouse_timestamps.remove_at(0)

	if not is_enabled or _velocity.is_zero_approx():
		_velocity = Vector2.ZERO

	if _velocity != Vector2.ZERO:
		# Apply velocity
		velocity_processed.emit(_velocity)
		# Reduce velocity
		_velocity *= pow(decay_rate, 60.0 * delta)


## Immediately sets velocity depending on recent mouse motion.
func start() -> void:
	_velocity = -_mouse_motion()


## Immediately sets velocity to zero.
func stop() -> void:
	_velocity = Vector2.ZERO
	_previous_mouse_positions.clear()
	_previous_mouse_timestamps.clear()


# Example:
# Say the positions are [(10,16), (12,20), (13,23)],
# the timestamps are [1, 2, 3], and the current mouse position is (13,24).
# Then the total_position_delta is (3,8)+(1,4)+(0,1)=(4,12),
# the total_time_delta is 3+2+1=6, and so the output is (0.67, 2).
#
## Returns the weighted average of the previous mouse positions.
func _mouse_motion() -> Vector2:
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
