class_name RecruitmentPopup
extends VBoxContainer
## Contents for the popup that appears
## when the user wants to recruit a new [Army].
##
## See also: [GamePopup]


signal confirmed(province: Province, troop_count: int)

var province: Province:
	set(value):
		province = value
		_update_costs()

var min_amount: int = 1:
	set(value):
		min_amount = maxi(1, value)
		_update_slider_min()

var max_amount: int = 1:
	set(value):
		max_amount = maxi(1, value)
		_update_slider_max()

@onready var _action_cost := %ActionCost as ActionCostNode
@onready var _troop_slider := %TroopSlider as Range
@onready var _troop_label := %TroopLabel as Label


func _ready() -> void:
	_update_costs()
	_update_slider_min()
	_update_slider_max()
	_troop_slider.value_changed.connect(_on_troop_slider_value_changed)
	_troop_slider.value = _troop_slider.max_value


func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func _update_costs() -> void:
	if not is_node_ready():
		return
	
	_action_cost.population_cost = ResourceCost.new(
			province.game.rules.recruitment_population_per_unit.value
	) if province else null
	
	_action_cost.money_cost = ResourceCost.new(
			province.game.rules.recruitment_money_per_unit.value
	) if province else null


func _update_number_to_buy() -> void:
	if not is_node_ready():
		return
	
	_action_cost.number_to_buy = roundi(_troop_slider.value)


func _update_slider_min() -> void:
	if not is_node_ready():
		return
	
	_troop_slider.min_value = min_amount


func _update_slider_max() -> void:
	if not is_node_ready():
		return
	
	_troop_slider.max_value = max_amount


func _update_troop_label() -> void:
	var value: int = roundi(_troop_slider.value)
	
	# Prevent a division by zero, just in case
	# this slider's maximum value is zero for some reason.
	var percentage: int = 100
	if max_amount != 0:
		percentage = floori(100.0 * value / float(max_amount))
	
	_troop_label.text = str(value) + " (" + str(percentage) + "%)"


func _on_troop_slider_value_changed(_value: float) -> void:
	_update_troop_label()
	_update_number_to_buy()


func _on_button_pressed(button_index: int) -> void:
	if button_index == 1:
		confirmed.emit(province, roundi(_troop_slider.value))
