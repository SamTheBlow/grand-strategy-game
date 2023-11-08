class_name GameTurn
extends Node


signal game_over()

@export_range(1, 2, 1, "or_greater") var _turn: int = 1


func _on_new_turn() -> void:
	_turn += 1
	
	propagate_call("_on_reached_turn", [_turn])


func _on_turn_limit_exceeded() -> void:
	game_over.emit()


func as_json() -> int:
	return _turn
