class_name ProvinceColorUpdate
extends Node
## Ensures a province's visuals always use the color of its country.

@export var _polygon: Polygon2D

## May be null.
var _owner_country: Country = null:
	set(value):
		if _owner_country != null:
			_owner_country.color_changed.disconnect(_refresh)

		_owner_country = value
		_refresh()

		if _owner_country != null:
			_owner_country.color_changed.connect(_refresh)

## The color to use when the province doesn't have an owner country.
@onready var _default_shape_color: Color = _polygon.color


func setup(province: Province) -> void:
	_set_owner_country(province)
	province.owner_changed.connect(_set_owner_country)


func _refresh() -> void:
	if _owner_country == null:
		_polygon.color = _default_shape_color
	else:
		_polygon.color = _owner_country.color


func _set_owner_country(province: Province) -> void:
	_owner_country = province.owner_country
