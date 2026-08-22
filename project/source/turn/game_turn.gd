class_name GameTurn
## Class responsible for a turn-based system.
## Each [Country] plays one at a time in order.
## After everyone is done playing, a new turn begins.
# TODO implement multiple players playing at the same time
# for now, assume the playing player is the first element in playing_players()

signal is_running_changed(is_running: bool)
## Emitted when the gameplay loop starts running.
signal started()
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
		if _is_running:
			started.emit()

var _turn: int = 1

## This is -1 if the game has not yet started.
var _playing_country_id: int = -1
## This is -1 if the game has not yet started.
var _playing_country_index: int = -1

var _ai_thread := AIThread.new()


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
	if not _is_running:
		return

	var player: GamePlayer = playing_players()[0]

	if not player.is_human:
		return

	_end_player_turn(player)


## Starts the gameplay loop, if possible.
## When it's an AI's turn, creates a new thread for the AI
## and waits for the thread to be finished.
func start() -> void:
	# Cannot start with 0 countries.
	# Please verify this before calling this function.
	if _game.countries.size() == 0:
		_playing_country_id = -1
		_playing_country_index = -1
		push_warning("Cannot start with 0 countries.")
		return

	# If playing country id is invalid, start at the first country in the list
	elif _game.countries.country_from_id(_playing_country_id) == null:
		_playing_country_id = _game.countries.country_from_index(0).id
		_playing_country_index = 0

	# Make sure country id and country index point at the same country
	else:
		_playing_country_index = (
				_game.countries.position_of(_playing_country_id)
		)

	if not _is_running:
		_game.countries.added.connect(_on_country_added)
		_game.countries.removed.connect(_on_country_removed)
		_game.countries.order_changed.connect(_on_country_order_changed)
		_is_running = true

	# Make sure the starting country has at least one player playing it
	_find_playing_country()
	if _is_running:
		_run_gameplay_loop()


# Stops the gameplay loop.
# Useful when it's an AI only game and you want the game loop to end.
func stop() -> void:
	if not _is_running:
		return

	_game.countries.added.disconnect(_on_country_added)
	_game.countries.removed.disconnect(_on_country_removed)
	_game.countries.order_changed.disconnect(_on_country_order_changed)
	_is_running = false


func _end_player_turn(player: GamePlayer) -> void:
	if not _is_running:
		return

	# Make army movements according to [AutoArrow]s
	if player.is_human:
		player.human_status_changed.disconnect(_end_player_turn)
		AutoArrowBehavior.apply(_game)

	# Merge armies
	for province_id in _game.world.armies_in_each_province.dictionary:
		_game.world.armies.merge_armies(
				_game.world.armies_in_each_province.dictionary[province_id]
				.ordered_list,
				player.playing_country
		)

	country_turn_ended.emit(player.playing_country)
	_playing_country_index += 1
	_refresh_playing_country()


func _refresh_playing_country() -> void:
	_find_playing_country()
	if _is_running:
		playing_country_changed.emit(playing_country())
	# Check again, just in case the signal causes the gameplay loop to end.
	if _is_running:
		_run_gameplay_loop()


## Ensures the playing country has at least one player playing it.
## Stops the gameplay loop if no valid country could be found.
func _find_playing_country() -> void:
	if _game.countries.size() == 0:
		_playing_country_id = -1
		_playing_country_index = -1
		push_warning("There are 0 countries. Stopping gameplay loop.")
		stop()
		return

	var scanned: int = 0
	while scanned < _game.countries.size():
		if _playing_country_index >= _game.countries.size():
			_playing_country_index = 0
			_turn += 1
			turn_changed.emit(_turn)

		_playing_country_id = (
				_game.countries.country_from_index(_playing_country_index).id
		)

		if not playing_players().is_empty():
			return

		_playing_country_index += 1
		scanned += 1

	_playing_country_id = -1
	_playing_country_index = -1
	push_warning("There is no playing player. Stopping gameplay loop.")
	stop()


func _run_gameplay_loop() -> void:
	var player: GamePlayer = playing_players()[0]

	# If the player is an AI, play their actions in a separate thread
	if not player.is_human:
		_ai_thread.run(_game, player, player.player_ai)
	# Automatically end a human player's turn if they become an AI
	else:
		player.human_status_changed.connect(
				_end_player_turn, ConnectFlags.CONNECT_ONE_SHOT
		)


func _on_country_added(_country: Country) -> void:
	_playing_country_index = _game.countries.position_of(_playing_country_id)


func _on_country_removed(country: Country) -> void:
	if country.id == _playing_country_id:
		_refresh_playing_country()
	else:
		_playing_country_index = (
				_game.countries.position_of(_playing_country_id)
		)


func _on_country_order_changed(
		_country_id: int, _old_index: int, _new_index: int
) -> void:
	_playing_country_index = _game.countries.position_of(_playing_country_id)


func _on_ai_finished(actions: Array[Action]) -> void:
	if not _is_running:
		return

	var player: GamePlayer = playing_players()[0]

	for action in actions:
		action.apply_to(_game, player)

	_end_player_turn(player)
