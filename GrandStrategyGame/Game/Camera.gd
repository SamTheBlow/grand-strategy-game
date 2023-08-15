extends Camera2D
# See: https://www.youtube.com/watch?v=gpvLqLggJuk


var target_zoom: float = 1.0
var max_zoom: float = 1.0
var zoom_increment: float = 0.075
var zoom_rate: float = 8.0


func _ready() -> void:
	get_tree().get_root().connect(
			"size_changed",
			Callable(self, "_on_screen_resize")
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var event_typed := event as InputEventMouseMotion
		if event_typed.button_mask == MOUSE_BUTTON_MASK_LEFT:
			position -= event_typed.relative / zoom
			# All of this assumes the camera's
			# anchor mode is Fixed TopLeft.
			var max_x: float = (
					limit_right - get_viewport_rect().size.x / zoom.x
			)
			var max_y: float = (
					limit_bottom - get_viewport_rect().size.y / zoom.y
			)
			position.x = clampf(position.x, 0.0, max_x)
			position.y = clampf(position.y, 0.0, max_y)
	elif event is InputEventMouseButton:
		var event_typed := event as InputEventMouseButton
		if event_typed.is_pressed():
			if event_typed.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_in()
			if event_typed.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_out()


func zoom_in() -> void:
	target_zoom = minf(target_zoom + zoom_increment, max_zoom)
	set_physics_process(true)


func zoom_out() -> void:
	target_zoom = maxf(target_zoom - zoom_increment, get_minimum_zoom())
	set_physics_process(true)


func get_minimum_zoom() -> float:
	# This ensures the camera always stays in bounds
	var min_zoom_x: float = get_viewport_rect().size.x / limit_right
	var min_zoom_y: float = get_viewport_rect().size.y / limit_bottom
	return maxf(min_zoom_x, min_zoom_y)


func _physics_process(delta: float) -> void:
	zoom = zoom.lerp(target_zoom * Vector2.ONE, zoom_rate * delta)
	set_physics_process(not is_equal_approx(zoom.x, target_zoom))


func _on_screen_resize() -> void:
	var minimum_zoom: float = get_minimum_zoom()
	if zoom.x < minimum_zoom or zoom.y < minimum_zoom:
		zoom = minimum_zoom * Vector2.ONE
		target_zoom = minimum_zoom
