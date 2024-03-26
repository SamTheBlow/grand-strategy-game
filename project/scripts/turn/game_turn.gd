class_name GameTurn
## Class responsible for a turn-based system.
## Each player plays one at a time in order.
## After everyone is done playing, a new turn begins.


## This signal is only called once all players have played their turn.
signal turn_changed(new_turn: int)
## This signal is called whenever it's a new player's turn to play.
signal player_changed(new_player: Player)

var game: Game

var _turn: int = 1
var _playing_player_index: int = 0


func current_turn() -> int:
	return _turn


## Returns a player: it's currently that player's turn to play.
func playing_player() -> Player:
	return game.players.player_from_index(_playing_player_index)


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
		army.stop_animations()
	
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
	if _playing_player_index >= game.players.size():
		_playing_player_index = 0
	
	player_changed.emit(playing_player())
	if _playing_player_index == 0:
		_turn += 1
		turn_changed.emit(_turn)
