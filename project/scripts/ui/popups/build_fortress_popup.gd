class_name BuildFortressPopup
extends VBoxContainer
## Contents for the popup that appears
## when the user wants to build a [Fortress].
##
## See [GamePopup] to learn more on how popups work.


signal confirmed(province: Province)

@export var cost_label: Label

var _province: Province


## To be called when this node is created.
func init(province: Province, cost: int) -> void:
	_province = province
	cost_label.text = "Build a fortress for " + str(cost) + " money?"


## See [GamePopup]
func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


## See [GamePopup]
func _on_button_pressed(button_index: int) -> void:
	if button_index == 1:
		confirmed.emit(_province)
