class_name BuildFortressPopup
extends VBoxContainer
## Contents for the popup that appears
## when the user wants to build a [Fortress].
##
## See also: [GamePopup]
# TODO a lot of copy/paste from [RecruitmentPopup]


signal confirmed(province: Province)

## This will be passed as an argument for the confirmed signal.
var province: Province

var _action_cost: ActionCostNode:
	get:
		if _action_cost == null:
			_action_cost = %ActionCost as ActionCostNode
		return _action_cost


func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func set_population_cost(population_cost: ResourceCost) -> void:
	_action_cost.population_cost = population_cost


func set_money_cost(money_cost: ResourceCost) -> void:
	_action_cost.money_cost = money_cost


func _on_button_pressed(button_index: int) -> void:
	if button_index == 1:
		confirmed.emit(province)
