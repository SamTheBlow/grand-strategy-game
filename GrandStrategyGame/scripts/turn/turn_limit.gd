class_name TurnLimit
## Class responsible for a game's turn limit.
## When the final turn is over, the game over signal is emitted.
##
## To use, call _on_new_turn() at the start of the new turn
## with the new turn number as the input.
## The game_over signal is only emitted at the start of a new turn.
## It's okay to edit the final_turn property at any time.


signal game_over()

var final_turn: int = 1


func _on_new_turn(turn: int) -> void:
	if turn > final_turn:
		game_over.emit()
