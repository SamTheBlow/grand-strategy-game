extends Control
class_name Draggable

var is_being_dragged:bool = false
var relative_starting_position:Vector2 = Vector2.ZERO
var relative_mouse_origin:Vector2 = Vector2.ZERO

func _process(_delta):
	if is_being_dragged:
		var relative_position:Vector2 = get_relative_mouse_position()
		var delta_x:float = relative_position.x - relative_mouse_origin.x
		var delta_y:float = relative_position.y - relative_mouse_origin.y
		var relative_width:float = anchor_right - anchor_left
		var relative_height:float = anchor_bottom - anchor_top
		anchor_left = relative_starting_position.x + delta_x
		anchor_right = anchor_left + relative_width
		anchor_top = relative_starting_position.y + delta_y
		anchor_bottom = anchor_top + relative_height

func _input(event):
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_being_dragged = false

# Connect signals to this
func _on_dragged():
	is_being_dragged = true
	relative_starting_position = Vector2(anchor_left, anchor_top)
	relative_mouse_origin = get_relative_mouse_position()

func get_relative_mouse_position() -> Vector2:
	var mouse_position:Vector2 = get_viewport().get_mouse_position()
	var window_size:Vector2 = get_viewport().get_visible_rect().size
	return Vector2( \
		mouse_position.x / window_size.x, \
		mouse_position.y / window_size.y)
