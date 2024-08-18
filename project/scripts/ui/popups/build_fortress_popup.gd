class_name BuildFortressPopup
extends VBoxContainer
## Contents for the popup that appears
## when the user wants to build a [Fortress].
##
## See [GamePopup] to learn more on how popups work.


signal confirmed(province: Province)

var province: Province:
	set(value):
		province = value
		_update_costs()

@onready var _action_cost := %ActionCost as ActionCostNode


func _ready() -> void:
	_update_costs()


func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func _update_costs() -> void:
	if _action_cost == null:
		return
	
	_action_cost.money_cost = (
			null if province == null else
			ResourceCost.new(province.game.rules.fortress_price.value)
	)


func _on_button_pressed(button_index: int) -> void:
	if button_index == 1:
		confirmed.emit(province)
