class_name GameSync
extends Node
## Creates and encapsulates the individual components
## for synchronizing given [Game] across clients.


func _init(game: Game) -> void:
	add_child(GameUsernameSync.new(game.game_players))
	add_child(AutoArrowSync.new(game))
	add_child(ActionSync.new(game))


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = "GameSync"
