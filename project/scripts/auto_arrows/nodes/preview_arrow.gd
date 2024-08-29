class_name AutoArrowPreviewNode2D
extends AutoArrowNode2D


## Emitted when the mouse click is released on a valid destination province.
signal released(this: AutoArrowPreviewNode2D)


func _ready() -> void:
	super()
	_update_pointing_position()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if _is_right_click_just_released(event as InputEventMouseButton):
			_release()
	elif event is InputEventMouseMotion:
		_update_pointing_position()


func _release() -> void:
	if destination_province != null:
		released.emit(self)
	
	queue_free()


## Moves the arrow's tip along with the cursor.
## Unsnaps from destination province when applicable.
func _update_pointing_position() -> void:
	if (
			destination_province != null
			and not destination_province.mouse_is_inside_shape()
	):
		destination_province = null
	
	global_pointing_position = (
			PositionScreenToWorld.new()
			.result(get_viewport().get_mouse_position(), get_viewport())
	)


func _is_right_click_just_released(event: InputEventMouseButton) -> bool:
	return (not event.pressed) and event.button_index == MOUSE_BUTTON_RIGHT


## Snaps the arrow to the province when applicable.
func _on_province_mouse_event_occured(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
) -> void:
	if not event is InputEventMouseMotion:
		return
	
	if province_visuals.province.is_linked_to(source_province.province):
		destination_province = province_visuals