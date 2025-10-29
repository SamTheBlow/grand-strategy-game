class_name ProvinceSelectConditions
extends Node
## Determines when a province is successfully selected.

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

## May be null.
var camera_drag_measurement: CameraDragMeasurement


func _camera_dragged_too_much() -> bool:
	if camera_drag_measurement == null:
		push_error("Drag measurement is null.")
		return false

	const MAX_DRAG_AMOUNT: float = 30.0
	var drag_amount: Vector2 = camera_drag_measurement.drag_amount()
	return (
			absf(drag_amount.x) > MAX_DRAG_AMOUNT
			or absf(drag_amount.y) > MAX_DRAG_AMOUNT
	)


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

	# If the camera was dragged too much, don't select the province
	if _camera_dragged_too_much():
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
	if world_visuals == null:
		return

	# If the camera was dragged too much, don't deselect
	if _camera_dragged_too_much():
		return

	world_visuals.province_selection.deselect()


class ProvinceSelectionOutcome:
	var is_selected: bool = true
