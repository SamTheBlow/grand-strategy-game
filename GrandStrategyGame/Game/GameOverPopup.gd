class_name GameOver
extends Draggable


func set_text(text: String):
	($ColorRect/MarginContainer/VBoxContainer/Winner as Label).text = text
