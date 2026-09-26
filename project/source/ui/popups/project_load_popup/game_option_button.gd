class_name GameOptionButton
extends AuthorityButton
## The button for a game option in some game selection menu.
## Draws a white outline around itself when selected.


func _ready() -> void:
	super()
	toggled.connect(queue_redraw.unbind(1))


func _draw() -> void:
	if button_pressed:
		draw_rect(Rect2(Vector2.ZERO, size), Color.WHITE, false, 1.5, true)
