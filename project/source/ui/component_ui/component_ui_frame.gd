@tool
class_name ComponentUIFrame
extends Control
## Draws the frame of a [ComponentUI].

@export_tool_button("Update") var update_button: Callable = update
@export var line_top: float
@export var line_bottom: float
@export var line_length_x: float
@export var line_width: float = 3.0


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


func update() -> void:
	var x: float = -(line_length_x + line_width)
	var y: float = line_top - line_width
	var width: float = line_length_x * 2.0 + line_width * 2.0
	var height: float = line_bottom - line_top + line_width * 2.0
	position = Vector2(x, y)
	size = Vector2(width, height)
	queue_redraw()
