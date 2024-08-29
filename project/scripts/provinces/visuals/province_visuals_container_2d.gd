class_name ProvinceVisualsContainer2D
extends Node2D


signal unhandled_mouse_event_occured(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
)
signal mouse_event_occured(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
)


func _ready() -> void:
	# WARNING: assumes that provinces are never added to the game later on
	for province_visuals in list():
		province_visuals.unhandled_mouse_event_occured.connect(
				_on_unhandled_province_mouse_event
		)
		province_visuals.mouse_event_occured.connect(_on_province_mouse_event)


func list() -> Array[ProvinceVisuals2D]:
	var output: Array[ProvinceVisuals2D] = []
	for child in get_children():
		if child is ProvinceVisuals2D:
			output.append(child)
	return output


func links_of(province: Province) -> Array[ProvinceVisuals2D]:
	var output: Array[ProvinceVisuals2D] = []
	for other_visuals in list():
		if other_visuals.province.is_linked_to(province):
			output.append(other_visuals)
	return output


## May return null.
func visuals_of(province: Province) -> ProvinceVisuals2D:
	for visuals in list():
		if visuals.province == province:
			return visuals
	return null


func _on_unhandled_province_mouse_event(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
) -> void:
	unhandled_mouse_event_occured.emit(event, province_visuals)


func _on_province_mouse_event(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
) -> void:
	mouse_event_occured.emit(event, province_visuals)
