class_name BuildFortressPopup
extends VBoxContainer


signal confirmed(province: Province)

@export var cost_label: Label

var _province: Province


## To be called when this node is created.
func init(province: Province, cost: int) -> void:
	_province = province
	cost_label.text = "Build a fortress for " + str(cost) + " money?"


func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func _on_button_pressed(button_index: int) -> void:
	if button_index == 1:
		confirmed.emit(_province)
