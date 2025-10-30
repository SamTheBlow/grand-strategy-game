class_name ProvinceSelection
## Determines which [Province] is currently selected.
## Allows getting or changing the currently selected province.
## Provides useful signals.

## Emitted when a province is deselected.
## Province may be null if the province no longer exists.
signal province_deselected(province: Province)
## Emitted when a province is selected.
signal province_selected(province: Province)
## Emitted when the selected province is changed or deselected.
## Province may be null if no province is selected.
signal selected_province_changed(province: Province)

## Attemping to select or deselect a province has no effect when disabled.
var is_disabled: bool = false:
	set(value):
		if value:
			_selected_province_id = -1
		is_disabled = value

var _provinces: Provinces

var _selected_province_id: int = -1:
	set(value):
		if is_disabled:
			return

		value = maxi(value, -1)

		if _selected_province_id == value:
			return

		if _selected_province_id != -1:
			province_deselected.emit(selected_province())

		_selected_province_id = value

		if _selected_province_id != -1:
			province_selected.emit(selected_province())

		selected_province_changed.emit(selected_province())


func _init(provinces := Provinces.new()) -> void:
	_provinces = provinces
	_provinces.removed.connect(_on_province_removed)


## Returns null if no province is selected.
func selected_province() -> Province:
	return _provinces.province_from_id(_selected_province_id)


## No effect if there is no province with given id.
func select(province_id: int) -> void:
	if _provinces.province_from_id(province_id) == null:
		return
	_selected_province_id = province_id


## Makes it so that no province is selected.
##
## Optionally, you may provide a specific province to deselect.
## In that case, only deselects given province.
func deselect(province_id: int = -1) -> void:
	if province_id > -1 and _selected_province_id != province_id:
		return
	_selected_province_id = -1


## Automatically deselect a province when it's removed.
func _on_province_removed(province: Province) -> void:
	if _selected_province_id == province.id:
		_selected_province_id = -1
