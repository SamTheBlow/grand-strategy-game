class_name CameraZoom
extends Node
## Zooms a camera in/out with the mouse wheel towards the cursor's position.
##
## Some of the code was originally borrowed from this video by Bramwell:
## https://www.youtube.com/watch?v=gpvLqLggJuk

## Emits the zoom to apply whenever its value changes.
signal zoom_changed(zoom: float)

## Emits at a fast rate with how far to pan the camera, in world units.
signal pan_processed(offset: Vector2)

## Try a value in-between 0 and 1.
@export var default_zoom: float = 1.0

var _minimum_zoom: float = -INF
var _maximum_zoom: float = INF

## The camera will do its best to reach this amount of zoom.
var _target_zoom: float = default_zoom:
	set(value):
		_previous_target = _target_zoom
		if is_equal_approx(_target_zoom, value):
			return
		_target_zoom = value
		set_physics_process(not is_equal_approx(_current_zoom, _target_zoom))

## Used to correctly zoom at the cursor's location.
var _previous_target: float = default_zoom

var _current_zoom: float = default_zoom:
	set(new_value):
		var old_value: float = _current_zoom
		_current_zoom = new_value
		set_physics_process(not is_equal_approx(_current_zoom, _target_zoom))
		if not is_equal_approx(old_value, new_value):
			zoom_changed.emit(_current_zoom)

## How far the camera still needs to pan, in world units.
var _movement: Vector2 = Vector2.ZERO

## How close/far the camera will zoom in/out each time.
var _zoom_increment: float = 0.075
## How fast the camera zooms in/out.
var _zoom_rate: float = 8.0
## If enabled, when zooming out, the camera will zoom away from the
## center of the viewport instead of zooming away from the cursor's position.
var _zoom_away_from_center: bool = true


func _ready() -> void:
	# Apply default zoom provided in scene export variable
	reset()


func _physics_process(delta: float) -> void:
	var weight: float = _zoom_rate * delta

	# Apply zoom lerp
	_current_zoom = lerpf(_current_zoom, _target_zoom, weight)

	# Pan the camera in the direction of the cursor
	if _movement != Vector2.ZERO:
		var step: Vector2 = _movement * weight
		_movement -= step
		pan_processed.emit(step)


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	var event_typed := event as InputEventMouseButton

	if event_typed.is_pressed():
		if event_typed.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_in(event_typed.position)
		if event_typed.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_out(event_typed.position)


## Resets all internal data.
func reset() -> void:
	_minimum_zoom = -INF
	_maximum_zoom = INF
	_target_zoom = default_zoom
	_previous_target = default_zoom
	_current_zoom = default_zoom
	_movement = Vector2.ZERO


## Sets the allowed zoom range.
func set_zoom_limits(minimum_zoom: float, maximum_zoom: float) -> void:
	_minimum_zoom = minimum_zoom
	_maximum_zoom = maximum_zoom
	_current_zoom = clampf(_current_zoom, _minimum_zoom, _maximum_zoom)
	_target_zoom = clampf(_target_zoom, _minimum_zoom, _maximum_zoom)


func _zoom_in(mouse_position: Vector2) -> void:
	_target_zoom = minf(_target_zoom + _zoom_increment, _maximum_zoom)
	_add_movement(mouse_position)


func _zoom_out(mouse_position: Vector2) -> void:
	_target_zoom = maxf(_target_zoom - _zoom_increment, _minimum_zoom)

	if _zoom_away_from_center:
		# Assuming the camera's anchor mode is Drag Center,
		# there is nothing we need to do
		pass
	else:
		_add_movement(mouse_position)


## Makes the camera zoom to the cursor's position.
func _add_movement(mouse_position: Vector2) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var offset_pixels: Vector2 = mouse_position - viewport_size * 0.5
	var zoom_before: Vector2 = Vector2.ONE / _previous_target
	var zoom_after: Vector2 = Vector2.ONE / _target_zoom
	_movement += offset_pixels * (zoom_before - zoom_after)
