class_name ProvinceSelection
extends Node
## Keeps track of which [Province] is currently selected.
## Emits relevant signals.

## Emitted when a province is deselected. The given province is never null.
signal province_deselected(province: Province)
## Emitted when a province is selected. The given province is never null.
signal province_selected(province: Province)
## Emitted when the selected_province property
## is assigned a different value (may be null).
signal selected_province_changed(province: Province)

## May be null, in which case no province is selected.
var selected_province: Province:
	set(value):
		if selected_province == value:
			return

		if selected_province != null:
			province_deselected.emit(selected_province)

		selected_province = value

		if selected_province != null:
			province_selected.emit(selected_province)

		selected_province_changed.emit(selected_province)


## Optionally, you may provide a specific province to deselect.
## No effect if that province is not selected.
func deselect_province(province_to_deselect: Province = null) -> void:
	if (
			province_to_deselect != null
			and selected_province != province_to_deselect
	):
		return
	selected_province = null
