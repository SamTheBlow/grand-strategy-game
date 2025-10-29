class_name CameraZoom
extends Node
## Allows the player to zoom the camera in/out.
## Automatically zooms in the direction of the cursor.
##
## See this video for more information about some of the code:
## https://www.youtube.com/watch?v=gpvLqLggJuk

@export var _camera: CustomCamera2D

## Try a value in-between 0 and 1.[br] If the value is too low or too high,
## the camera will use the minimum or maximum zoom.
@export var default_zoom: float = 1.0

## The camera will do its best to reach this amount of zoom.
var _target_zoom: float = 1.0
## The previous zoom target is used to correctly zoom at the cursor's location.
var _previous_target: float = 1.0
## The direction and magnitude of the camera's movement.
var _camera_movement: Vector2 = Vector2.ZERO

## The limit on how close the camera can zoom in.
var _maximum_zoom_limit: float = 1.0
## How close/far the camera will zoom in/out each time.
var _zoom_increment: float = 0.075
## How fast the camera zooms in/out.
var _zoom_rate: float = 8.0
## If enabled, when zooming out, the camera will zoom away from the
## center of the viewport instead of zooming away from the cursor's position.
var _zoom_away_from_center: bool = true


func _ready() -> void:
	# We have to wait one frame,
	# otherwise the minimum zoom is calculated incorrectly.
	await get_tree().process_frame

	# Zoom the camera to the default value
	_target_zoom = clampf(default_zoom, _minimum_zoom(), _maximum_zoom())
	_previous_target = _target_zoom
	_camera.zoom = Vector2.ONE * _target_zoom

	get_tree().get_root().size_changed.connect(_on_screen_size_changed)
	_connect_world_limits(_camera.world_limits)


func _physics_process(delta: float) -> void:
	var weight: float = _zoom_rate * delta

	# Apply the zoom
	_camera.zoom = _camera.zoom.lerp(_target_zoom * Vector2.ONE, weight)

	# Move the camera in the direction of the cursor
	var camera_position: Vector2 = _camera.position_in_bounds(_camera.position)
	var camera_to: Vector2 = camera_position + _camera_movement
	var lerped_position: Vector2 = _camera.position.lerp(camera_to, weight)
	_camera.position = _camera.position_in_bounds(lerped_position)
	_camera_movement = camera_to - _camera.position

	set_physics_process(not is_equal_approx(_camera.zoom.x, _target_zoom))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_typed := event as InputEventMouseButton
		if event_typed.is_pressed():
			if event_typed.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_in(event_typed.position)
			if event_typed.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_out(event_typed.position)


func _zoom_in(mouse_position: Vector2) -> void:
	_previous_target = _target_zoom
	_target_zoom = minf(_target_zoom + _zoom_increment, _maximum_zoom())
	_zoom_to_cursor(mouse_position)
	set_physics_process(true)


func _zoom_out(mouse_position: Vector2) -> void:
	_previous_target = _target_zoom
	_target_zoom = maxf(_target_zoom - _zoom_increment, _minimum_zoom())

	if _zoom_away_from_center:
		# Assuming the camera's anchor mode is Drag Center,
		# there is nothing we need to do
		pass
	else:
		_zoom_to_cursor(mouse_position)

	set_physics_process(true)


## Makes the camera zoom to the cursor's position.
func _zoom_to_cursor(mouse_position: Vector2) -> void:
	var viewport_size: Vector2 = _camera.get_viewport_rect().size
	var offset_pixels: Vector2 = mouse_position - viewport_size * 0.5
	var current_zoom: Vector2 = Vector2.ONE / _previous_target
	var new_zoom: Vector2 = Vector2.ONE / _target_zoom
	_camera_movement += offset_pixels * (current_zoom - new_zoom)


func _maximum_zoom() -> float:
	# Prevents glitches for the edge case where the minimum zoom is
	# larger than the maximum zoom. When this happens, we ignore
	# the maximum zoom and stay at the minimum zoom.
	return maxf(_maximum_zoom_limit, _minimum_zoom())


## Returns the minimum zoom amount.
## Currently, you can zoom out such that the world takes half the screen.
func _minimum_zoom() -> float:
	# Prevent division by zero
	if (
			_camera.world_limits.width() == 0.0
			or _camera.world_limits.height() == 0.0
	):
		return 1.0

	return 0.5 * minf(
			_camera.get_viewport_rect().size.x / _camera.world_limits.width(),
			_camera.get_viewport_rect().size.y / _camera.world_limits.height()
	)


func _keep_camera_in_bounds() -> void:
	var minimum_zoom: float = _minimum_zoom()
	if _camera.zoom.x < minimum_zoom or _camera.zoom.y < minimum_zoom:
		_camera.zoom = minimum_zoom * Vector2.ONE
		_target_zoom = minimum_zoom
		return

	var maximum_zoom: float = _maximum_zoom()
	if _camera.zoom.x > maximum_zoom or _camera.zoom.y > maximum_zoom:
		_camera.zoom = maximum_zoom * Vector2.ONE
		_target_zoom = maximum_zoom


func _connect_world_limits(world_limits: WorldLimits) -> void:
	if world_limits == null:
		push_error("World limits is null.")
		return

	if not world_limits.current_limits_changed.is_connected(_on_world_limits_changed):
		world_limits.current_limits_changed.connect(_on_world_limits_changed)


func _disconnect_world_limits(world_limits: WorldLimits) -> void:
	if world_limits == null:
		push_error("World limits is null.")
		return

	if world_limits.current_limits_changed.is_connected(_on_world_limits_changed):
		world_limits.current_limits_changed.disconnect(_on_world_limits_changed)


## Ensures the camera stays in bounds when the screen size changes.
func _on_screen_size_changed() -> void:
	_keep_camera_in_bounds()


## Idem for when the world limits change.
func _on_world_limits_changed(_world_limits: WorldLimits) -> void:
	_keep_camera_in_bounds()
