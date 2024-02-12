class_name GameTurn
extends Node


signal turn_changed(new_turn: int)

@export_range(1, 2, 1, "or_greater") var _turn: int = 1


func current_turn() -> int:
	return _turn


func _on_new_turn() -> void:
	_turn += 1
	turn_changed.emit(_turn)
	
	propagate_call("_on_reached_turn", [_turn])
