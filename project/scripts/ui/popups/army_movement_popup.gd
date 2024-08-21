class_name ArmyMovementPopup
extends VBoxContainer
## Contents for the popup that appears when the user wants to move an [Army].
##
## See also: [GamePopup]
# TODO DRY. This code is very similar to that of [RecruitmentPopup].


signal confirmed(army: Army, troop_count: int, destination: Province)

@export var troop_slider: Slider
@export var troop_label: Label

var _army: Army
var _destination: Province


## To be called when this node is created.
func init(army: Army, destination: Province) -> void:
	_army = army
	_destination = destination
	troop_slider.min_value = _army.game.rules.minimum_army_size.value
	troop_slider.max_value = _army.army_size.current_size()
	troop_slider.value = troop_slider.max_value
	_new_slider_value()


func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func _new_slider_value() -> void:
	var value := int(troop_slider.value)
	var max_value := int(troop_slider.max_value)
	troop_label.text = str(value) + " | " + str(max_value - value)


func _on_troop_slider_value_changed(value: float) -> void:
	if (
			value >
			troop_slider.max_value - _army.game.rules.minimum_army_size.value
			and value < troop_slider.max_value
	):
		# We return early, because setting the slider's value here
		# triggers the signal that calls this function
		troop_slider.value = troop_slider.max_value
		return
	
	_new_slider_value()


func _on_button_pressed(button_id: int) -> void:
	if button_id == 1:
		var troop_count := int(troop_slider.value)
		confirmed.emit(_army, troop_count, _destination)
