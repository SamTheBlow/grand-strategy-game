class_name ProvincesBlueprintFromData
extends ProvincesBlueprint
## A class for building a provinces blueprint from some data struture.


@warning_ignore("unused_private_class_variable")
var _error: int # This is a ParseError
@warning_ignore("unused_private_class_variable")
var _version: int


func _init() -> void:
	_error = ParseError.NO_DATA


static func _unit_test() -> void:
	# Nothing to test yet
	pass
