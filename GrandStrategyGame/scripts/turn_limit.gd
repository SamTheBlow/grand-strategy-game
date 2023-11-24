class_name TurnLimit
extends Node
## This node is meant to be added as a child of a GameTurn node.
## When the final turn is over, the game over signal is emitted.


signal game_over()

@export var _final_turn: int = 50


func _on_reached_turn(turn: int) -> void:
	if turn > _final_turn:
		game_over.emit()
