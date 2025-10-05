class_name PauseMenu
extends Control

signal resume_pressed()
signal save_pressed()
signal quit_pressed()
signal save_and_quit_pressed()


func _on_resume_button_pressed() -> void:
	resume_pressed.emit()


func _on_save_button_pressed() -> void:
	save_pressed.emit()


func _on_quit_button_pressed() -> void:
	quit_pressed.emit()


func _on_save_and_quit_button_pressed() -> void:
	save_and_quit_pressed.emit()
