class_name RecruitUI
extends Control


signal cancelled
signal move_troops

var army: Army
var source: Province
var destination: Province


func _on_Cancel_pressed() -> void:
	emit_signal("cancelled")
	queue_free()


func _on_Confirm_pressed() -> void:
	var troop_count := int(troop_slider().value)
	if troop_count != 0:
		emit_signal("move_troops", army, troop_count, source, destination)
	queue_free()


func _on_troop_slider_value_changed(value: float) -> void:
	update_troop_display(troop_slider().value, troop_slider().max_value)


func setup(army_: Army, source_: Province, destination_: Province) -> void:
	army = army_
	source = source_
	destination = destination_
	var slider: Slider = troop_slider()
	slider.max_value = army.troop_count
	slider.value = slider.max_value
	update_troop_display(slider.value, slider.max_value)


func troop_slider() -> Slider:
	return $Draggable/MarginContainer/VBoxContainer/TroopSlider as Slider


func troop_info() -> Label:
	return $Draggable/MarginContainer/VBoxContainer/TroopNumber as Label


func update_troop_display(value: float, max_value: float) -> void:
	troop_info().text = str(value) + " | " + str(max_value - value)
