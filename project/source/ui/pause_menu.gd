class_name PauseMenu
extends Control

signal save_requested()
signal quit_requested()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		visible = not visible
		get_viewport().set_input_as_handled()


func _on_save_button_pressed() -> void:
	save_requested.emit()


func _on_quit_button_pressed() -> void:
	quit_requested.emit()


func _on_save_and_quit_button_pressed() -> void:
	save_requested.emit()
	quit_requested.emit()
