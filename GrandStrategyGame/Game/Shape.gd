# Some code was borrowed from here:
# https://godotengine.org/qa/3963/is-it-possible-to-have-a-polygon2d-with-outline
extends Polygon2D

signal clicked

# Draw status:
# 0 - unselected
# 1 - selected
# 2 - neighbouring the selected province (target)
# 3 - neighbouring the selected province
var draw_status:int = 0 : set = set_draw_status
var outline_color:Color = Color.WEB_GRAY : set = set_outline_color
var outline_width:float = 10.0 : set = set_width

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_position = get_viewport().get_mouse_position()
		var mouse_position_in_world = mouse_position / get_viewport().get_camera_2d().zoom + get_viewport().get_camera_2d().position
		var local_mouse_position = mouse_position_in_world - global_position
		if Geometry2D.is_point_in_polygon(local_mouse_position, polygon):
			get_viewport().set_input_as_handled()
			emit_signal("clicked")

func _draw():
	if draw_status == 0:
		pass
	elif draw_status == 1:
		draw_outline(get_polygon(), outline_color, outline_width)
	elif draw_status == 2:
		draw_outline(get_polygon(), outline_color, outline_width * 0.8)
	elif draw_status == 3:
		draw_outline(get_polygon(), outline_color, outline_width * 0.5)

func draw_outline(poly, ocolor, width):
	var radius = width * 0.5
	draw_circle(poly[0], radius, ocolor)
	for i in range(1, poly.size()):
		draw_line(poly[i - 1], poly[i], ocolor, width)
		draw_circle(poly[i], radius, ocolor)
	draw_line(poly[poly.size() - 1], poly[0], ocolor, width)

func set_draw_status(draw_status_:int):
	draw_status = draw_status_
	queue_redraw()

func set_outline_color(outline_color_:Color):
	outline_color = outline_color_
	queue_redraw()

func set_width(outline_width_:float):
	outline_width = outline_width_
	queue_redraw()
