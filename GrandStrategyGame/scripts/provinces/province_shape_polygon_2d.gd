class_name ProvinceShapePolygon2D
extends Polygon2D
# See:
# https://godotengine.org/qa/3963/is-it-possible-to-have-a-polygon2d-with-outline


signal clicked()

# Draw status:
# 0 - unselected
# 1 - selected
# 2 - neighbouring the selected province (target)
# 3 - neighbouring the selected province
var draw_status: int = 0 : set = set_draw_status
var outline_color := Color.WEB_GRAY : set = set_outline_color
var outline_width: float = 10.0 : set = set_width


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_typed := event as InputEventMouseButton
		if (
				event_typed.pressed
				and not event_typed.is_echo()
				and event_typed.button_index == MOUSE_BUTTON_LEFT
		):
			var mouse_position: Vector2 = get_viewport().get_mouse_position()
			var camera: Camera2D = get_viewport().get_camera_2d()
			var mouse_position_in_world: Vector2 = (
					(mouse_position - get_viewport_rect().size * 0.5)
					/ camera.zoom
					+ camera.get_screen_center_position()
			)
			var local_mouse_position: Vector2 = (
					mouse_position_in_world - global_position
			)
			if Geometry2D.is_point_in_polygon(local_mouse_position, polygon):
				get_viewport().set_input_as_handled()
				clicked.emit()


func _draw() -> void:
	if draw_status == 0:
		pass
	elif draw_status == 1:
		draw_outline(get_polygon(), outline_color, outline_width)
	elif draw_status == 2:
		draw_outline(get_polygon(), outline_color, outline_width * 0.8)
	elif draw_status == 3:
		draw_outline(get_polygon(), outline_color, outline_width * 0.5)


func draw_outline(
		poly: PackedVector2Array,
		ocolor: Color,
		width: float
) -> void:
	var radius: float = width * 0.5
	draw_circle(poly[0], radius, ocolor)
	for i in range(1, poly.size()):
		draw_line(poly[i - 1], poly[i], ocolor, width)
		draw_circle(poly[i], radius, ocolor)
	draw_line(poly[poly.size() - 1], poly[0], ocolor, width)


func set_draw_status(value: int) -> void:
	draw_status = value
	queue_redraw()


func set_outline_color(value: Color) -> void:
	outline_color = value
	queue_redraw()


func set_width(value: float) -> void:
	outline_width = value
	queue_redraw()
