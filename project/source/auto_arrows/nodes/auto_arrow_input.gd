class_name AutoArrowInput
extends Node
## Creates the preview arrow that appears when the user holds right click.


## Emitted when the user double right clicks on given province.
signal province_double_right_clicked(province: Province)
## Emitted when the user releases a valid [AutoArrowPreviewNode2D].
signal auto_arrow_formed(auto_arrow: AutoArrow)

@export var auto_arrow_sync: AutoArrowSync
@export var province_container: ProvinceVisualsContainer2D
@export var auto_arrow_container: AutoArrowContainer

var playing_country: PlayingCountry


func _setup_new_preview_arrow(province_visuals: ProvinceVisuals2D) -> void:
	if not auto_arrow_sync.can_apply_changes(playing_country.country()):
		return
	
	var preview_arrow := AutoArrowPreviewNode2D.new()
	preview_arrow.source_province = province_visuals
	preview_arrow.released.connect(_on_preview_arrow_released)
	province_container.province_mouse_entered.connect(
			preview_arrow._on_province_mouse_entered
	)
	province_container.province_mouse_exited.connect(
			preview_arrow._on_province_mouse_exited
	)
	
	(
			auto_arrow_container.arrows_of_country(playing_country.country())
			.add_child(preview_arrow)
	)


func _is_right_click_just_pressed(event: InputEventMouseButton) -> bool:
	return event.pressed and event.button_index == MOUSE_BUTTON_RIGHT


func _on_provinces_unhandled_mouse_event_occured(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_button_event := event as InputEventMouseButton
	
	if not _is_right_click_just_pressed(mouse_button_event):
		return
	
	if mouse_button_event.double_click:
		province_double_right_clicked.emit(province_visuals.province)
	
	_setup_new_preview_arrow(province_visuals)
	get_viewport().set_input_as_handled()


func _on_preview_arrow_released(preview_arrow: AutoArrowPreviewNode2D) -> void:
	auto_arrow_formed.emit(preview_arrow.auto_arrow())
