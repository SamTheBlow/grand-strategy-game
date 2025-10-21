class_name BuildFortressPopup
extends VBoxContainer
## Contents for the popup that appears
## when the user wants to build a [Fortress].
##
## See also: [GamePopup]

signal invalidated()
signal confirmed(province_id: int)

var _is_invalid: bool = false

var _is_setup: bool = false
var _provinces: Provinces
var _province_id: int
var _resource_costs: Array[ResourceCost]

@onready var _action_cost := %ActionCost as ActionCostNode


func _ready() -> void:
	if _is_setup:
		_update()


func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func setup(
		provinces: Provinces,
		province_id: int,
		resource_costs: Array[ResourceCost]
) -> void:
	if _is_setup:
		_provinces.removed.disconnect(_on_province_removed)

	_provinces = provinces
	_province_id = province_id
	_resource_costs = resource_costs
	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	if _provinces.province_from_id(_province_id) == null:
		_is_invalid = true
		invalidated.emit()
		return

	_provinces.removed.connect(_on_province_removed)

	_action_cost.setup(_resource_costs)


func _on_button_pressed(button_index: int) -> void:
	if button_index == 1:
		confirmed.emit(_province_id)


func _on_province_removed(province: Province) -> void:
	if province.id == _province_id:
		_is_invalid = true
		_provinces.removed.disconnect(_on_province_removed)
		invalidated.emit()
