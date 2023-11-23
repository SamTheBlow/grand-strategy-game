class_name MainMenu
extends Node


signal game_started()


func _on_start_game_requested() -> void:
	game_started.emit()
