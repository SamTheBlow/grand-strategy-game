extends Draggable
class_name GameOver

func set_text(text:String):
	$ColorRect/MarginContainer/VBoxContainer/Winner.text = text
