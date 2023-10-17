class_name ProvincesBlueprint
extends Control
## A provinces blueprint is a blueprint for building provinces on a world map.
##
## It defines the most barebones information about provinces:
## their ID and their shape.[br]
## The blueprint also defines how many provinces the world map contains.


# Each province has a unique ID.
var _province_ids: PackedInt32Array

# Each province has a shape.
var _province_shapes: Array[ProvinceShape]


## Note: this object is not meant to be instantiated directly.
## Instead, a subclass should build it for you.
func _init(
		province_ids: PackedInt32Array,
		province_shapes: Array[ProvinceShape]
) -> void:
	_province_ids = province_ids
	_province_shapes = province_shapes


static func _unit_test() -> void:
	# Nothing to test yet
	pass
