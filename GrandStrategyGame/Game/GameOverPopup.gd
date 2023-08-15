class_name GameOver
extends Draggable


func set_text(text: String) -> void:
	($ColorRect/MarginContainer/VBoxContainer/Winner as Label).text = text
