extends Control

signal move_troops

var army:Army
var destination:Province

func setup(army_:Army, destination_:Province):
	army = army_
	destination = destination_
	var troop_slider = $MarginContainer/VBoxContainer/TroopSlider
	troop_slider.max_value = army.troop_count
	troop_slider.value = troop_slider.max_value

func _on_Cancel_pressed():
	queue_free()

func _on_Confirm_pressed():
	var troop_count = $MarginContainer/VBoxContainer/TroopSlider.value
	if troop_count != 0:
		emit_signal("move_troops", army, troop_count, destination)
	queue_free()
