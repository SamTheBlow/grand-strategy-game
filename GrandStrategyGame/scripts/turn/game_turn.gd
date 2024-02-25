class_name GameTurn
extends Node


signal turn_changed(new_turn: int)
signal player_changed(new_player: Player)

@export_range(1, 2, 1, "or_greater") var _turn: int = 1

var game: Game

var _playing_player_index: int = 0


func _on_new_turn() -> void:
	_turn += 1
	turn_changed.emit(_turn)
	
	propagate_call("_on_reached_turn", [_turn])


func current_turn() -> int:
	return _turn


func playing_player() -> Player:
	return game.players.players[_playing_player_index]


## Call this when a human player ends their turn.
func end_turn() -> void:
	_end_player_turn()
	loop()


## Plays out each player's turn, one at a time.
## ALERT if there are no human players, this causes an infinite loop!
func loop() -> void:
	while true:
		var player: Player = playing_player()
		if player.is_human:
			game.set_human_player(player)
			return
		
		# The player is an AI. Play their actions and end their turn
		player.play_actions(game)
		_end_player_turn()


func _end_player_turn() -> void:
	# Merge armies
	for province in game.world.provinces.get_provinces():
		game.world.armies.merge_armies(province)
	
	# Refresh the army visuals
	for army in game.world.armies.armies:
		army.refresh_visuals()
	
	for province in game.world.provinces.get_provinces():
		# Update province ownership
		ProvinceNewOwner.new().update_province_owner(province)
		
		# For debugging, check if there's more than one army on any province
		if game.world.armies.armies_in_province(province).size() > 1:
			print_debug(
					"At the end of a player's turn, found more than "
					+ "one army in province (ID: " + str(province.id) + ")."
			)
	
	_playing_player_index += 1
	if _playing_player_index >= game.players.players.size():
		_playing_player_index = 0
	
	player_changed.emit(playing_player())
	if _playing_player_index == 0:
		# TODO get rid of the propagate_call
		# Connect methods to the turn_changed signal instead
		game.propagate_call("_on_new_turn")
