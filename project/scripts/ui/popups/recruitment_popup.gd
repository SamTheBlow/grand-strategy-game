class_name RecruitmentPopup
extends VBoxContainer
## Contents for the popup that appears
## when the user wants to recruit a new [Army].
##
## See [GamePopup] to learn more on how popups work.
# TODO this code is VERY similar to that of [ArmyMovementPopup]


signal confirmed(province: Province, troop_count: int)

@export var troop_slider: Slider
@export var troop_label: Label

var _province: Province


## To be called when this node is created.
func init(province: Province, min_amount: int, max_amount: int) -> void:
	_province = province
	troop_slider.min_value = maxi(1, min_amount)
	troop_slider.max_value = max_amount
	troop_slider.value = troop_slider.max_value
	_new_slider_value()


## See [GamePopup]
func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func _new_slider_value() -> void:
	var value := int(troop_slider.value)
	var max_value := int(troop_slider.max_value)
	var percentage: int = 100
	if max_value == 0:
		print_debug(
				"Prevented a division by zero error. "
				+ "This slider's maximum value is zero for some reason."
		)
	else:
		percentage = floori(100.0 * value / float(max_value))
	
	troop_label.text = str(value) + " (" + str(percentage) + "%)"


func _on_troop_slider_value_changed(_value: float) -> void:
	_new_slider_value()


## See [GamePopup]
func _on_button_pressed(button_index: int) -> void:
	if button_index == 1:
		confirmed.emit(_province, roundi(troop_slider.value))
