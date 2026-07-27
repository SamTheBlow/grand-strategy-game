class_name GameTurn
## Class responsible for a turn-based system.
## Each [Country] plays one at a time in order.
## After everyone is done playing, a new turn begins.
# TODO implement multiple players playing at the same time
# for now, assume the playing player is the first element in playing_players()

signal is_running_changed(is_running: bool)
## Emitted once all countries have played their turn.
signal turn_changed(new_turn: int)
## Emitted when a country's turn ends, before the next country's turn begins.
signal country_turn_ended(country: Country)
## Emitted the moment it becomes a different country's turn to play.
signal playing_country_changed(country: Country)

var _game: Game

var _is_running: bool = false:
	set(value):
		if _is_running == value:
			return
		_is_running = value
		is_running_changed.emit(_is_running)

var _turn: int = 1

## This is -1 if the game has not yet started.
var _playing_country_id: int = -1

var _ai_thread := AIThread.new()

# When true, doesn't play the next country's turn after the AI submits
# their moves, and calling "start()" has no effect.
var _is_gameplay_loop_interrupted: bool = false


func _init(
		game: Game, starting_turn: int = 1, playing_country_id: int = -1
) -> void:
	_game = game
	_turn = starting_turn
	_playing_country_id = playing_country_id
	_ai_thread.finished.connect(_on_ai_finished)


## Returns true if the gameplay loop is currently running.
func is_running() -> bool:
	return _is_running


func current_turn() -> int:
	return _turn


## Returns a country: it's currently that country's turn to play.
## Only use this while the gameplay loop is running.
## Returns null if game has not yet started.
func playing_country() -> Country:
	return _game.countries.country_from_id(_playing_country_id)


## Returns a list of all players whose country is the current playing country.
func playing_players() -> Array[GamePlayer]:
	var country: Country = playing_country()
	if country == null:
		return []

	var output: Array[GamePlayer] = []
	for player in _game.game_players.list():
		if player.playing_country == country:
			output.append(player)
	return output


## Ends the player's turn. Has no effect if the player is an AI.
func end_turn() -> void:
	var player: GamePlayer = playing_players()[0]

	if not player.is_human:
		return

	_end_player_turn(player)


## Starts the gameplay loop, if possible.
## When it's an AI's turn, creates a new thread for the AI
## and waits for the thread to be finished.
func start() -> void:
	if _is_gameplay_loop_interrupted:
		return

	# Cannot start with 0 countries.
	# Please verify this before calling this function.
	if _game.countries.size() == 0:
		_playing_country_id = -1
		push_error("Cannot start with 0 countries.")
		return
	elif _playing_country_id == -1:
		_playing_country_id = _game.countries.country_from_index(0).id

	_is_running = true

	var players: Array[GamePlayer] = playing_players()

	# Don't wait on players if there is no player playing this country
	if players.size() == 0:
		_go_to_next_country()

	var player: GamePlayer = players[0]

	# If the player is an AI, play their actions in a separate thread
	if not player.is_human:
		_ai_thread.run(_game, player, player.player_ai)


# Stops the gameplay loop.
# Useful when it's an AI only game and you want the game loop to end.
func stop() -> void:
	_is_running = false
	_is_gameplay_loop_interrupted = true


func _end_player_turn(player: GamePlayer) -> void:
	# Make army movements according to [AutoArrow]s
	if player.is_human:
		AutoArrowBehavior.apply(_game)

	# Merge armies
	for armies_in_province in _game.world.armies_in_each_province.values():
		_game.world.armies.merge_armies(
				armies_in_province, player.playing_country
		)

	country_turn_ended.emit(player.playing_country)
	_go_to_next_country()
	start()


func _go_to_next_country() -> void:
	var playing_country_index: int = (
			_game.countries.position_of(_playing_country_id) + 1
	)

	if playing_country_index >= _game.countries.size():
		playing_country_index = 0

		_playing_country_id = _game.countries.country_from_index(0).id

		_turn += 1
		turn_changed.emit(_turn)
	else:
		_playing_country_id = (
				_game.countries.country_from_index(playing_country_index).id
		)

	playing_country_changed.emit(playing_country())


func _on_ai_finished(actions: Array[Action]) -> void:
	if _is_gameplay_loop_interrupted:
		return

	var player: GamePlayer = playing_players()[0]

	for action in actions:
		action.apply_to(_game, player)

	_end_player_turn(player)
