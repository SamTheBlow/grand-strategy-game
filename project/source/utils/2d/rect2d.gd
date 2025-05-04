@tool
class_name Rect2D
extends Node2D
## Draws a rectangle on screen.
## [br][br]
## You can use this node's [member CanvasItem.modulate]
## to change the rectangle color.
## [br][br]
## After you modify a property through code, please remember to
## call [method CanvasItem.queue_redraw]: it is not done automatically.

## The rectangle to draw on screen.
@export var rectangle := Rect2(0.0, 0.0, 10_000.0, 10_000.0)


func _draw() -> void:
	draw_rect(rectangle, modulate, false)
