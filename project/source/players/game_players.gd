class_name GamePlayers
## A list of [GamePlayer] instances.
## Provides useful functions and signals.

signal added(game_player: GamePlayer)
signal removed(game_player: GamePlayer)
signal username_changed(game_player: GamePlayer)

## The list, as an array.
## It's exposed for performance reasons. Do not edit this list!
var list: Array[GamePlayer] = []

## The list, as a dictionary. Maps a player id to its player.
## Use this list to quickly get a player by its id.
## It's exposed for performance reasons. Do not edit this list!
var map: Dictionary[int, GamePlayer] = {}

var _countries: Countries
var _unique_id_system := UniqueIdSystem.new()


func _init(countries: Countries) -> void:
	_countries = countries
	countries.removed.connect(_on_country_removed)


## If given player's id is invalid (i.e. a negative number),
## automatically gives it a new unique id.
##
## No effect if given player's id is already in use,
## or if given player is already in the list.
func add(game_player: GamePlayer) -> void:
	_add(game_player)


## No effect if given player is not on the list.
func remove(game_player_id: int) -> void:
	if not map.has(game_player_id):
		return
	var game_player: GamePlayer = map[game_player_id]

	game_player.username_changed.disconnect(username_changed.emit)
	map.erase(game_player_id)
	list.erase(game_player)

	# We have to unclaim the id because, if we want to bring this player
	# back in the list later with the same id, the id needs to not be in use.
	_unique_id_system.unclaim_id(game_player_id)

	removed.emit(game_player)


## Removes a player, using given [UndoRedoResource] system.
## Ensures that when we undo, everything is exactly as it was before.
func undo_redo_remove(
		game_player: GamePlayer, undo_redo: UndoRedoResource
) -> void:
	if not map.has(game_player.id):
		return

	undo_redo.create_action("Delete player")
	undo_redo.add_do_method(remove.bind(game_player.id))

	# Ensure the player's position in the list is restored on undo
	undo_redo.add_undo_method(_add.bind(game_player, list.find(game_player)))

	undo_redo.commit_action()


func number_of_humans() -> int:
	var output: int = 0
	for game_player in list:
		if game_player.is_human():
			output += 1
	return output


## The number of humans in this list, minus the spectators.
func number_of_playing_humans() -> int:
	var output: int = 0
	for game_player in list:
		if game_player.is_human() and not game_player.is_spectating():
			output += 1
	return output


## The number of humans in this list, minus remote players.
func number_of_local_humans() -> int:
	var output: int = 0
	for game_player in list:
		if game_player.is_human() and not game_player.player_human.is_remote():
			output += 1
	return output


## Returns true if you control given country.
## ("you" means not an AI and not controlled by a different client)
func you_control_country(multiplayer: MultiplayerAPI, country: Country) -> bool:
	return client_controls_country(
			multiplayer.get_unique_id()
			if MultiplayerUtils.is_online(multiplayer) else 1,
			country
	)


## Returns true if the client (given by its unique id) has one or more
## players playing as the given country, otherwise returns false.
func client_controls_country(multiplayer_id: int, country: Country) -> bool:
	for game_player in list:
		if (
				game_player.is_human()
				and game_player.player_human.multiplayer_id == multiplayer_id
				and game_player.playing_country == country
		):
			return true
	return false


## Keeps the insertion index a private feature.
func _add(game_player: GamePlayer, insertion_index: int = -1) -> void:
	if map.has(game_player.id):
		push_warning("Player is already in the list.")
		return

	if (
			game_player.playing_country != null
			and not _countries.list.has(game_player.playing_country)
	):
		push_warning(
				"Player's playing country is not in the game's list. "
				+ "Demoting the player to a spectator."
		)
		game_player.playing_country = null

	if not _unique_id_system.is_id_valid(game_player.id):
		game_player.id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(game_player.id):
		push_warning("Id (%s) is already in use." % game_player.id)
		return
	else:
		_unique_id_system.claim_id(game_player.id)

	map[game_player.id] = game_player

	if insertion_index < 0 or insertion_index >= list.size():
		list.append(game_player)
	else:
		list.insert(insertion_index, game_player)

	game_player.username_changed.connect(username_changed.emit)

	added.emit(game_player)


# TODO move this to a different class
## When a country is removed from the game,
## any player who was controlling that country becomes a spectator.
func _on_country_removed(country: Country) -> void:
	for game_player in list:
		if game_player.playing_country == country:
			game_player.playing_country = null
