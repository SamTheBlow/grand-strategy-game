@tool
class_name Arrow2D
extends Node2D
## Draws an arrow with given properties.

@export var arrow_tip_angle: float = deg_to_rad(30.0):
	set(value):
		arrow_tip_angle = value
		queue_redraw()

@export var arrow_tip_length: float = 50.0:
	set(value):
		arrow_tip_length = value
		queue_redraw()

@export var arrow_color: Color = Color.GOLD:
	set(value):
		arrow_color = value
		queue_redraw()

@export var arrow_thickness: float = 8.0:
	set(value):
		arrow_thickness = value
		queue_redraw()

## Where the arrows points at, relative to this node's position.
@export var position_tip := Vector2.ZERO:
	set(value):
		position_tip = value
		queue_redraw()


func _draw() -> void:
	draw_line(Vector2.ZERO, position_tip, arrow_color, arrow_thickness)
	draw_line(
			position_tip,
			position_tip - (position_tip)
			.rotated(arrow_tip_angle).normalized() * arrow_tip_length,
			arrow_color,
			arrow_thickness
	)
	draw_line(
			position_tip,
			position_tip - (position_tip)
			.rotated(-arrow_tip_angle).normalized() * arrow_tip_length,
			arrow_color,
			arrow_thickness
	)
