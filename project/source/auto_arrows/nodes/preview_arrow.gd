class_name AutoArrowPreviewNode2D
extends AutoArrowNode2D
## The arrow that appears when creating a new AutoArrow.
## Points at the mouse cursor's location, or, when applicable,
## points at the province the mouse cursor is on.
## When right click is released, emits a signal and deletes itself.

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
func _update_pointing_position() -> void:
	global_pointing_position = get_global_mouse_position()


func _is_right_click_just_released(event: InputEventMouseButton) -> bool:
	return (not event.pressed) and event.button_index == MOUSE_BUTTON_RIGHT


## Snaps the arrow to the province when applicable.
func _on_province_mouse_entered(province_visuals: ProvinceVisuals2D) -> void:
	if province_visuals.province.is_linked_to(source_province.province.id):
		destination_province = province_visuals


## Unsnaps the arrow from the province when applicable.
func _on_province_mouse_exited(province_visuals: ProvinceVisuals2D) -> void:
	if province_visuals == destination_province:
		destination_province = null
