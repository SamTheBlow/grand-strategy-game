extends Camera2D
# See also: https://www.youtube.com/watch?v=gpvLqLggJuk


# The camera will do its best to reach this amount of zoom
var _target_zoom: float = 1.0

# The limit on how close the camera can zoom in
var _max_zoom: float = 1.0
# How close/far the camera will zoom in/out each time
var _zoom_increment: float = 0.075
# How fast the camera zooms in/out
var _zoom_rate: float = 8.0


func _ready() -> void:
	get_tree().get_root().connect(
			"size_changed", Callable(self, "_on_screen_size_changed")
	)


func _physics_process(delta: float) -> void:
	zoom = zoom.lerp(_target_zoom * Vector2.ONE, _zoom_rate * delta)
	set_physics_process(not is_equal_approx(zoom.x, _target_zoom))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_typed := event as InputEventMouseButton
		if event_typed.is_pressed():
			if event_typed.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_in()
			if event_typed.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_out()


func zoom_in() -> void:
	_target_zoom = minf(_target_zoom + _zoom_increment, _max_zoom)
	set_physics_process(true)


func zoom_out() -> void:
	_target_zoom = maxf(_target_zoom - _zoom_increment, _minimum_zoom())
	set_physics_process(true)


func _minimum_zoom() -> float:
	# This ensures the camera always stays in bounds
	var min_zoom_x: float = get_viewport_rect().size.x / limit_right
	var min_zoom_y: float = get_viewport_rect().size.y / limit_bottom
	return maxf(min_zoom_x, min_zoom_y)


func _on_screen_size_changed() -> void:
	var minimum_zoom: float = _minimum_zoom()
	if zoom.x < minimum_zoom or zoom.y < minimum_zoom:
		zoom = minimum_zoom * Vector2.ONE
		_target_zoom = minimum_zoom
