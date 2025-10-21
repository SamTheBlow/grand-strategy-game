class_name RecruitmentPopup
extends VBoxContainer
## Contents for the popup that appears
## when the user wants to recruit a new [Army].
##
## See also: [GamePopup]

signal invalidated()
signal confirmed(troop_count: int, province_id: int)

var _is_invalid: bool = false

var _is_setup: bool = false
var _provinces: Provinces
var _province_id: int
var _resource_costs: Array[ResourceCost]
var _minimum_amount: int
var _maximum_amount: int

@onready var _action_cost := %ActionCost as ActionCostNode
@onready var _troop_slider := %TroopSlider as Range
@onready var _troop_label := %TroopLabel as Label


func _ready() -> void:
	if _is_setup:
		_update()


func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func setup(
		provinces: Provinces,
		province_id: int,
		resource_costs: Array[ResourceCost],
		minimum_amount: int,
		maximum_amount: int
) -> void:
	if _is_setup:
		_provinces.removed.disconnect(_on_province_removed)

	_provinces = provinces
	_province_id = province_id
	_resource_costs = resource_costs
	_minimum_amount = minimum_amount
	_maximum_amount = maximum_amount
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
	_troop_slider.min_value = maxi(1, _minimum_amount)
	_troop_slider.max_value = maxi(1, _maximum_amount)

	# Have the slider maxed out by default
	_troop_slider.value = _troop_slider.max_value

	_update_troop_label()
	_update_number_to_buy()
	_troop_slider.value_changed.connect(_on_troop_slider_value_changed)


func _update_number_to_buy() -> void:
	_action_cost.number_to_buy = roundi(_troop_slider.value)


func _update_troop_label() -> void:
	var value: int = roundi(_troop_slider.value)
	var max_value: float = _troop_slider.max_value

	# Prevent a division by zero, just in case
	# this slider's maximum value is zero for some reason.
	var percentage: int = 100
	if max_value != 0.0:
		percentage = floori(100.0 * value / max_value)

	_troop_label.text = str(value) + " (" + str(percentage) + "%)"


func _on_troop_slider_value_changed(_value: float) -> void:
	_update_troop_label()
	_update_number_to_buy()


func _on_button_pressed(button_index: int) -> void:
	if button_index == 1:
		confirmed.emit(roundi(_troop_slider.value), _province_id)


func _on_province_removed(province: Province) -> void:
	if province.id == _province_id:
		_is_invalid = true
		_provinces.removed.disconnect(_on_province_removed)
		invalidated.emit()
