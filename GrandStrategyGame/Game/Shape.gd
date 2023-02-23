# Code was borrowed from here:
# https://godotengine.org/qa/3963/is-it-possible-to-have-a-polygon2d-with-outline
extends Polygon2D

# Draw status:
# 0 - unselected
# 1 - selected
# 2 - neighbouring the selected province (target)
# 3 - neighbouring the selected province
var draw_status = 0 setget set_draw_status
var outline_color = Color.webgray setget set_color
var outline_width = 10.0 setget set_width

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

func set_draw_status(status):
	draw_status = status
	update()

func set_color(color):
	outline_color = color
	update()

func set_width(new_width):
	outline_width = new_width
	update()
