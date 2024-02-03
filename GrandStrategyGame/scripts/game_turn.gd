class_name GameTurn
extends Node


@export_range(1, 2, 1, "or_greater") var _turn: int = 1


func _on_new_turn() -> void:
	_turn += 1
	
	propagate_call("_on_reached_turn", [_turn])
