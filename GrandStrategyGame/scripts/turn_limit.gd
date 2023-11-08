extends Node


signal exceeded()

@export var final_turn: int = 10


func _on_reached_turn(turn: int) -> void:
	if turn > final_turn:
		exceeded.emit()
