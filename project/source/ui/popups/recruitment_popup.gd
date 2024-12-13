class_name RecruitmentPopup
extends VBoxContainer
## Contents for the popup that appears
## when the user wants to recruit a new [Army].
##
## See also: [GamePopup]

signal confirmed(province: Province, troop_count: int)

## This will be passed as an argument for the confirmed signal.
var province: Province

var _action_cost: ActionCostNode:
	get:
		if _action_cost == null:
			_action_cost = %ActionCost as ActionCostNode
		return _action_cost

var _troop_slider: Range:
	get:
		if _troop_slider == null:
			_troop_slider = %TroopSlider as Range
		return _troop_slider

@onready var _troop_label := %TroopLabel as Label


func _ready() -> void:
	# Have the slider maxed out by default
	_troop_slider.value = _troop_slider.max_value

	_update_troop_label()
	_update_number_to_buy()
	_troop_slider.value_changed.connect(_on_troop_slider_value_changed)


func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func set_population_cost(population_cost: ResourceCost) -> void:
	_action_cost.population_cost = population_cost


func set_money_cost(money_cost: ResourceCost) -> void:
	_action_cost.money_cost = money_cost


func set_minimum_amount(min_amount: int) -> void:
	_troop_slider.min_value = maxi(1, min_amount)


func set_maximum_amount(max_amount: int) -> void:
	_troop_slider.max_value = maxi(1, max_amount)


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
		confirmed.emit(province, roundi(_troop_slider.value))
