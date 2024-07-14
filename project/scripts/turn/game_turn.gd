class_name GameTurn
## Class responsible for a turn-based system.
## Each [GamePlayer] plays one at a time in order.
## After everyone is done playing, a new turn begins.


## This signal is only called once all players have played their turn.
signal turn_changed(new_turn: int)
## This signal is called whenever it's a different player's turn to play.
signal player_changed(new_player: GamePlayer)

## External reference
var game: Game

var _turn: int = 1
## DANGER this implementation depends on the fact that
## the [GamePlayers] player order never changes
var _playing_player_index: int = 0


func current_turn() -> int:
	return _turn


## Returns a player: it's currently that player's turn to play.
func playing_player() -> GamePlayer:
	return game.game_players.player_from_index(_playing_player_index)


## Call this when a user ends their turn.
func end_turn() -> void:
	_end_player_turn()
	loop()


## Plays out each player's turn, one at a time.
## ALERT if there are no human players, this causes an infinite loop!
func loop() -> void:
	if game.game_players.number_of_playing_humans() == 0:
		push_warning(
				"Started the game loop with no playing humans. "
				+ "There will probably be an infinite loop."
		)
		#for player in game.game_players.list():
		#	print(player.username, " (HUMAN)" if player.is_human else " (AI)")
	
	while true:
		# Uncomment this to watch how an AI-only game ends :D
		#if game._game_over:
		#	break
		
		var player: GamePlayer = playing_player()
		
		if player.is_spectating():
			_go_to_next_player()
			continue
		
		if player.is_human:
			return
		
		# The player is an AI. Play their actions and end their turn
		var actions: Array[Action] = player.player_ai.actions(game, player)
		for action in actions:
			action.apply_to(game, player)
		_end_player_turn()


func _end_player_turn() -> void:
	# Make army movements according to [AutoArrow]s
	AutoArrowBehavior.new().apply(game)
	
	# Exhaust all the armies
	# HACK this is so that they all merge properly
	# TODO whether or not an army is active
	# should never matter if it's not the player's turn
	for army in game.world.armies.list():
		if army.owner_country == playing_player().playing_country:
			army.exhaust()
	
	# Merge armies, update province ownership
	for province in game.world.provinces.list():
		game.world.armies.merge_armies(province)
		ProvinceNewOwner.new().update_province_owner(province)
	
	_go_to_next_player()


func _go_to_next_player() -> void:
	_playing_player_index += 1
	if _playing_player_index >= game.game_players.size():
		_playing_player_index = 0
	
	player_changed.emit(playing_player())
	if _playing_player_index == 0:
		_turn += 1
		turn_changed.emit(_turn)
