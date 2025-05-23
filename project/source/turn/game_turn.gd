class_name GameTurn
## Class responsible for a turn-based system.
## Each [GamePlayer] plays one at a time in order.
## After everyone is done playing, a new turn begins.

signal is_running_changed(is_running: bool)
## This signal is only called once all players have played their turn.
signal turn_changed(new_turn: int)
## Emitted after a player ends their turn, but before the next player's turn.
signal player_turn_ended(playing_player: GamePlayer)
## This signal is called whenever it's a different player's turn to play.
signal player_changed(new_player: GamePlayer)

var _game: Game

var _is_running: bool = false:
	set(value):
		if _is_running == value:
			return
		_is_running = value
		is_running_changed.emit(_is_running)

var _turn: int = 1

# TODO It's probably not impossible to create a save file that
# loads the game with a spectator as the current playing player,
# in which case there is no check for this, and the game will surely crash.
# DANGER This implementation depends on the fact that
# the [GamePlayers] player order never changes.
var _playing_player_index: int = 0

var _ai_thread := AIThread.new()

# When true, doesn't play the next player's turn after the AI submits
# their moves, and calling "start()" has no effect.
var _is_gameplay_loop_interrupted: bool = false


func _init(
		game: Game,
		starting_turn: int = 1,
		playing_player_index: int = 0
) -> void:
	_game = game
	_turn = starting_turn
	_playing_player_index = playing_player_index
	_ai_thread.finished.connect(_on_ai_finished)


## Returns true if the gameplay loop is currently running.
func is_running() -> bool:
	return _is_running


func current_turn() -> int:
	return _turn


## Returns a player: it's currently that player's turn to play.
## Only use this while the gameplay loop is running.
func playing_player() -> GamePlayer:
	return _game.game_players.player_from_index(_playing_player_index)


## Ends a human player's turn. Has no effect if it's an AI's turn to play.
func end_turn() -> void:
	if not playing_player().is_human:
		return

	_end_player_turn()


## Starts the gameplay loop, if possible.
## Skips spectators. When it's an AI's turn, creates a new thread for the AI
## and waits for the thread to be finished.
func start() -> void:
	if _is_gameplay_loop_interrupted:
		return

	# Cannot start with 0 players.
	# Please verify this before calling this function.
	if _game.game_players.size() == 0:
		push_error("Cannot start with 0 players.")
		return

	_is_running = true

	var player: GamePlayer = playing_player()

	# Skip spectators
	if player.is_spectating():
		_go_to_next_player()
		start()
		return

	if player.is_human:
		return

	# The player is an AI. Play their actions in a separate thread.
	_ai_thread.run(_game, player, player.player_ai)


# Stops the gameplay loop.
# Useful when it's an AI only game and you want the game loop to end.
func stop() -> void:
	_is_running = false
	_is_gameplay_loop_interrupted = true


func _end_player_turn() -> void:
	var player: GamePlayer = playing_player()

	# Make army movements according to [AutoArrow]s
	if player.is_human:
		AutoArrowBehavior.new().apply(_game)

	# Merge armies
	for province in _game.world.armies_in_each_province.dictionary:
		_game.world.armies.merge_armies(
				_game.world.armies_in_each_province.dictionary[province],
				player.playing_country
		)

	player_turn_ended.emit(player)
	_go_to_next_player()
	start()


func _go_to_next_player() -> void:
	_playing_player_index += 1

	if _playing_player_index >= _game.game_players.size():
		_playing_player_index = 0
		_turn += 1
		turn_changed.emit(_turn)

	# Spectators cannot be the playing player.
	# WARNING: if somehow all the players are spectators,
	# this will freeze the game in an infinite loop.
	if playing_player().is_spectating():
		_go_to_next_player()
		return

	player_changed.emit(playing_player())


func _on_ai_finished(actions: Array[Action]) -> void:
	if _is_gameplay_loop_interrupted:
		return

	for action in actions:
		action.apply_to(_game, playing_player())

	_end_player_turn()
