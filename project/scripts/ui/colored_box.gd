@tool
class_name ColoredBox
extends Control


@export var box_global_position := Vector2.ZERO
@export var box_size := Vector2.ZERO

@export var inside_color := Color.WHITE
@export var outline_color := Color.WHITE
@export var is_outline_inside: bool = true

## The left and right margin between the text and the box, in pixels.
@export var left_right_margin: float = 0.0:
	set(value):
		left_right_margin = value
		queue_redraw()

## The top and bottom margin between the text and the box, in pixels.
@export var top_bottom_margin: float = 0.0:
	set(value):
		top_bottom_margin = value
		queue_redraw()

## The width of the colored outline around the box.
@export var outline_width: float = 0.0:
	set(value):
		outline_width = value
		queue_redraw()


func _draw() -> void:
	var x: float = -left_right_margin
	var y: float = -top_bottom_margin
	var width: float = box_size.x + left_right_margin * 2.0
	var height: float = box_size.y + top_bottom_margin * 2.0
	
	if is_outline_inside:
		draw_rect(Rect2(x, y, width, height), outline_color)
		draw_rect(
				Rect2(
						outline_width,
						outline_width,
						width - outline_width * 2.0,
						height - outline_width * 2.0
				),
				inside_color
		)
		return
	
	if outline_width > 0.0:
		draw_rect(
				Rect2(
						x - outline_width,
						y - outline_width,
						width + outline_width * 2.0,
						height + outline_width * 2.0
				),
				outline_color
		)
	draw_rect(Rect2(x, y, width, height), inside_color)
