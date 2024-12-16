class_name MainMenu
extends Node

signal play_clicked()
signal make_clicked()


func _on_play_button_pressed() -> void:
	play_clicked.emit()


func _on_make_button_pressed() -> void:
	make_clicked.emit()
