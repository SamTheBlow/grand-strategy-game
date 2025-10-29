class_name ProvinceSelectConditions
extends Node
## Determines when a province is successfully selected.
## Deselects a province when clicking on the background.

## Anyone can change the outcome from the outside.
## By default, the outcome is that the province will be selected.
signal province_select_attempted(
		province: Province, outcome: ProvinceSelectionOutcome
)

var world_visuals: WorldVisuals2D:
	set(value):
		if world_visuals != null:
			world_visuals.province_visuals.unhandled_mouse_event_occured.disconnect(_on_province_unhandled_mouse_event)
			world_visuals.background.clicked.disconnect(_on_background_clicked)
		world_visuals = value
		if world_visuals != null:
			world_visuals.province_visuals.unhandled_mouse_event_occured.connect(_on_province_unhandled_mouse_event)
			world_visuals.background.clicked.connect(_on_background_clicked)


func _on_province_unhandled_mouse_event(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
) -> void:
	# Only proceed when the input is a left click
	if not (event is InputEventMouseButton):
		return
	var event_button := event as InputEventMouseButton
	if not event_button.button_index == MOUSE_BUTTON_LEFT:
		return
	get_viewport().set_input_as_handled()

	if world_visuals == null:
		return

	# Only select the province when the click is released
	if event_button.pressed:
		return

	var province: Province = province_visuals.province

	# If the province is already selected, deselect it and return
	if world_visuals.province_selection.selected_province() == province:
		world_visuals.province_selection.deselect()
		return

	# Let others veto it
	var outcome := ProvinceSelectionOutcome.new()
	province_select_attempted.emit(province, outcome)
	if outcome.is_selected:
		world_visuals.province_selection.select(province.id)


func _on_background_clicked() -> void:
	if world_visuals != null:
		world_visuals.province_selection.deselect()


class ProvinceSelectionOutcome:
	var is_selected: bool = true
