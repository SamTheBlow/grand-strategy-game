class_name PlayersSyncCheck
## This will tell you if the Players node is done synchronizing.
## It's done synchronizing when all of its players are done.


signal sync_finished()

var number_of_players: int = 0
var _players_done: int = 0


func is_sync_finished() -> bool:
	return _players_done == number_of_players


func _on_player_sync_finished(player: Player) -> void:
	player.sync_finished.disconnect(_on_player_sync_finished)
	_players_done += 1
	if _players_done == number_of_players:
		sync_finished.emit()
