class_name ProvinceSelection
## Keeps track of which [Province] is currently selected.
## Allows selecting or deselecting a province.
## Provides useful signals.

## Emitted when a province is deselected.
signal province_deselected(province: Province)
## Emitted when a province is selected.
signal province_selected(province: Province)
## Emitted when the selected province has changed.
## Province may be null if no province is selected.
signal selected_province_changed(province: Province)

## Attemping to select or deselect a province has no effect when disabled.
var is_disabled: bool = false:
	set(value):
		if value:
			deselect()
		is_disabled = value

## May be null, in which case no province is currently selected.
var selected_province: Province = null:
	set(value):
		if is_disabled:
			return

		if selected_province == value:
			return

		if selected_province != null:
			province_deselected.emit(selected_province)

		selected_province = value

		if selected_province != null:
			province_selected.emit(selected_province)

		selected_province_changed.emit(selected_province)


## No effect if input is null.
func select(province: Province) -> void:
	if province == null:
		return
	selected_province = province


## Optionally, you may provide a specific province to deselect.
## In that case, only deselects when given province is the selected province.
func deselect(province: Province = null) -> void:
	if province != null and province != selected_province:
		return
	selected_province = null
