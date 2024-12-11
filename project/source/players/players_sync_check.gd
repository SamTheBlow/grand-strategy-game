class_name PlayersSyncCheck
extends SyncCheck
## This will tell you if and when a [Players] node is done synchronizing.
## It's done synchronizing when all of its individual players are done.


func _init(players: Players) -> void:
	_number_of_things_to_check = players.size()
	for player in players.list():
		player.sync_finished.connect(_on_sync_finished)
