class_name GameTurn
## Class responsible for a turn-based system.
## Each [GamePlayer] plays one at a time in order.
## After everyone is done playing, a new turn begins.


## This signal is only called once all players have played their turn.
signal turn_changed(new_turn: int)
## Emitted after a player ends their turn, but before the next player's turn.
signal player_turn_ended(playing_player: GamePlayer)
## This signal is called whenever it's a different player's turn to play.
signal player_changed(new_player: GamePlayer)

## External reference
var game: Game

var _turn: int = 1

# TODO It's probably not impossible to create a save file that
# loads the game with a spectator as the current playing player,
# in which case there is no check for this, and the game will surely crash.
# DANGER This implementation depends on the fact that
# the [GamePlayers] player order never changes.
var _playing_player_index: int = 0

var _is_not_asked_to_stop: bool


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
## NOTE: if the game has no human players, an infinite loop occurs!
## In that case, consider using stop() to break the loop at some point.
func loop() -> void:
	if game.game_players.number_of_playing_humans() == 0:
		push_warning(
				"Running the game loop with no human players! "
				+ "This will cause an infinite loop."
		)
	
	_is_not_asked_to_stop = true
	while _is_not_asked_to_stop:
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


## Forces the loop to break. Has no effect if the loop is not running.
func stop() -> void:
	_is_not_asked_to_stop = false


func _end_player_turn() -> void:
	var player: GamePlayer = playing_player()
	
	# Make army movements according to [AutoArrow]s
	if player.is_human:
		AutoArrowBehavior.new().apply(game)
	
	# Exhaust all the armies
	# HACK this is so that they all merge properly
	# TODO whether or not an army is active
	# should never matter if it's not the player's turn
	for army in game.world.armies.list():
		if army.owner_country == player.playing_country:
			army.exhaust()
	
	# Merge armies
	for province in game.world.provinces.list():
		game.world.armies.merge_armies(province)
	
	_go_to_next_player()


func _go_to_next_player() -> void:
	player_turn_ended.emit(playing_player())
	
	while true:
		_playing_player_index += 1
		
		if _playing_player_index >= game.game_players.size():
			_playing_player_index = 0
			_turn += 1
			turn_changed.emit(_turn)
		
		# Spectators cannot be the playing player.
		# WARNING: if somehow all the players are spectators,
		# this will freeze the game in an infinite loop.
		if playing_player().is_spectating():
			continue
		
		break
	
	player_changed.emit(playing_player())
