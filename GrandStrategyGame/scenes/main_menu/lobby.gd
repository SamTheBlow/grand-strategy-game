class_name Lobby
extends Control


signal start_game_requested()


func _on_start_button_pressed() -> void:
	start_game_requested.emit()
