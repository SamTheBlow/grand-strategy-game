class_name ComponentUIFrame
extends Control
## Draws the frame of a [ComponentUI].


var line_top: float
var line_bottom: float
var line_length_x: float
var line_width: float = 3.0


func _draw() -> void:
	# Top line
	draw_line(
			-position + Vector2(-line_length_x, line_top),
			-position + Vector2(line_length_x, line_top),
			Color.BLACK,
			line_width
	)
	draw_line(
			-position + Vector2(-line_length_x, line_top),
			-position + Vector2(line_length_x, line_top),
			Color.WHITE
	)
	# Left line
	draw_line(
			-position + Vector2(-line_length_x, line_top),
			-position + Vector2(-line_length_x, line_bottom),
			Color.BLACK,
			line_width
	)
	draw_line(
			-position + Vector2(-line_length_x, line_top),
			-position + Vector2(-line_length_x, line_bottom),
			Color.WHITE
	)
	# Right line
	draw_line(
			-position + Vector2(line_length_x, line_top),
			-position + Vector2(line_length_x, line_bottom),
			Color.BLACK,
			line_width
	)
	draw_line(
			-position + Vector2(line_length_x, line_top),
			-position + Vector2(line_length_x, line_bottom),
			Color.WHITE
	)


func update_node_transform() -> void:
	var x: float = -(line_length_x + line_width)
	var y: float = line_top - line_width
	var width: float = line_length_x * 2.0 + line_width * 2.0
	var height: float = line_bottom - line_top + line_width * 2.0
	position = Vector2(x, y)
	size = Vector2(width, height)
