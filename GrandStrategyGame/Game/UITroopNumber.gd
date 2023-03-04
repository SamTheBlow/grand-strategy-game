extends Control

signal cancelled
signal move_troops

var army:Army
var source:Province
var destination:Province

func setup(army_:Army, source_:Province, destination_:Province):
	army = army_
	source = source_
	destination = destination_
	var troop_slider = $Draggable/MarginContainer/VBoxContainer/TroopSlider
	troop_slider.max_value = army.troop_count
	troop_slider.value = troop_slider.max_value

func _on_Cancel_pressed():
	emit_signal("cancelled")
	queue_free()

func _on_Confirm_pressed():
	var troop_count:int = $Draggable/MarginContainer/VBoxContainer/TroopSlider.value
	if troop_count != 0:
		emit_signal("move_troops", army, troop_count, source, destination)
	queue_free()
