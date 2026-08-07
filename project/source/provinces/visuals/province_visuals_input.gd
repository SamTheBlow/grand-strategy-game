class_name ProvinceVisualsInput
extends Node
## - Keeps track of which province is currently hovered.
## - Adds or removes highlight on province visuals accordingly.
## - Selects or deselects provinces through [ProvinceSelection].
## - Emits useful signals.

## Allows listeners to cancel the selection.
## By default, the outcome is that the province will be selected.
signal province_select_attempted(
		province: Province, outcome: ProvinceSelectionOutcome
)

## Emitted when a province's hover outline is removed.
signal province_unhovered()

var _province_selection: ProvinceSelection = null
var _hovered_province: Province = null

@onready var _province_container := %Provinces as ProvinceVisualsContainer2D


## Selects given province, or deselects if input is null.
## No effect if the province is already selected.
func set_selected_province(province: Province) -> void:
	if _province_selection == null:
		return
	_province_selection.selected_province = province


## Sets it to none if input is empty or null.
## No effect if province is already the hovered one.
func set_hovered_province(province: Province = null) -> void:
	if _province_selection == null:
		return
	if province == _hovered_province:
		return

	var previous_province: Province = _hovered_province
	_hovered_province = province

	if (
			previous_province != null
			and previous_province != _province_selection.selected_province
	):
		var previous_visuals: ProvinceVisuals2D = (
				_province_container.visuals_of(previous_province.id)
		)
		if previous_visuals != null:
			previous_visuals.remove_highlight()
			province_unhovered.emit()

	if province == null:
		return

	if province != _province_selection.selected_province:
		var visuals: ProvinceVisuals2D = (
				_province_container.visuals_of(province.id)
		)
		if visuals != null:
			visuals.highlight()


func _on_world_loaded(world_visuals: WorldVisuals2D) -> void:
	_province_selection = world_visuals.province_selection

	# Highlight the currently selected province
	var selected_province: Province = _province_selection.selected_province
	if selected_province != null:
		_highlight_province(selected_province)

	_province_selection.province_selected.connect(_highlight_province)
	_province_selection.province_deselected.connect(_on_deselected)


func _highlight_province(province: Province) -> void:
	_province_container.visuals_of(province.id).highlight_selected()


## We use this and not set_hovered_province(null),
## because if a different province got hovered and got their
## mouse_entered signal to trigger first, then they'd set the
## hovered province to the new province, and then the previous province visuals
## would trigger mouse_exited and set it back to null.
func _unset_hovered_province(province_visuals: ProvinceVisuals2D) -> void:
	if province_visuals.province != _hovered_province:
		return

	_hovered_province = null

	if province_visuals.province != _province_selection.selected_province:
		province_visuals.remove_highlight()
		province_unhovered.emit()


func _on_background_clicked() -> void:
	if _province_selection != null:
		_province_selection.deselect()


func _on_province_clicked(province: Province) -> void:
	# Clicking on an already selected province deselects it
	if _province_selection.selected_province == province:
		_province_selection.selected_province = null
		return

	# Allow listeners to deny selection
	var outcome := ProvinceSelectionOutcome.new()
	province_select_attempted.emit(province, outcome)

	if outcome.is_selected:
		# Deselect first (prevents crash)
		_province_selection.selected_province = null
		_province_selection.selected_province = province


func _on_mouse_entered(province_visuals: ProvinceVisuals2D) -> void:
	set_hovered_province(province_visuals.province)


func _on_deselected(province: Province) -> void:
	var visuals: ProvinceVisuals2D = _province_container.visuals_of(province.id)
	if visuals == null:
		return
	visuals.remove_highlight()
	if province == _hovered_province:
		visuals.highlight()


class ProvinceSelectionOutcome:
	var is_selected: bool = true
