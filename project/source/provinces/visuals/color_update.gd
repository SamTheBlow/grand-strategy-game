class_name ProvinceColorUpdate
extends Node
## Updates the color of given polygon
## to match the color of some province's owner country.

@export var _polygon: Polygon2D

## May be null.
var _owner_country: Country:
	set(value):
		if _owner_country != null:
			_owner_country.color_changed.disconnect(_update)
		_owner_country = value
		_update()
		if _owner_country != null:
			_owner_country.color_changed.connect(_update)

## The color defined in the editor will be the default color
## when the province doesn't have a valid owner country.
@onready var _default_shape_color: Color = _polygon.color


func _ready() -> void:
	_update()


## Meant to be called only once.
func setup(province: Province) -> void:
	_owner_country = province.owner_country
	province.owner_changed.connect(_on_owner_changed)


func _update() -> void:
	if not is_node_ready():
		return

	if _owner_country == null:
		_polygon.color = _default_shape_color
	else:
		_polygon.color = _owner_country.color


func _on_owner_changed(province: Province) -> void:
	_owner_country = province.owner_country
