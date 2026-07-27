@tool
class_name TurnOrderList
extends Control
## Displays a list of [GamePlayers] in the order in which
## they will play their turn. Shows with an arrow whose turn it is to play.
## Allows the user to rename players and add/remove human players.

signal new_human_player_requested(game_player: GamePlayer)
signal player_removal_requested(player: Player)

## The root node of this scene must be a [TurnOrderElement].
const _ELEMENT_SCENE: PackedScene = preload("uid://p440ahx3w70n")

## If true, shrinks down to the size of the contents.
## Otherwise, uses position/anchors as usual.
## Do not change this while the game is running.
@export var is_shrunk: bool = true:
	set(value):
		is_shrunk = value
		if is_node_ready():
			_refresh_node_size()

## The number of pixels that separate the list's contents from the edges.
@export var margin_pixels: int = 16:
	set(value):
		margin_pixels = value
		if is_node_ready():
			_set_margin_offsets()
			_refresh_node_size()

var countries: Countries:
	set(value):
		if countries != null:
			countries.added.disconnect(_on_country_added)
			countries.removed.disconnect(_on_country_removed)
			countries.order_changed.disconnect(_on_order_changed)
		countries = value
		_refresh_list()
		countries.added.connect(_on_country_added)
		countries.removed.connect(_on_country_removed)
		countries.order_changed.connect(_on_order_changed)

var players: GamePlayers:
	set(value):
		if players != null:
			players.player_added.disconnect(_on_player_added)
			players.player_removed.disconnect(_on_player_removed)
		players = value
		_refresh_list()
		players.player_added.connect(_on_player_added)
		players.player_removed.connect(_on_player_removed)

## Allows showing with an arrow whose turn it is to play.
## May be null, in which case this feature is disabled.
var game_turn: GameTurn = null:
	set(value):
		game_turn = value

		for player in _element_nodes:
			_element_nodes[player].turn = game_turn

var _element_nodes: Dictionary[GamePlayer, TurnOrderElement] = {}

## Stores the players in country order. Used for sorting.
var _players_of_country: Array[PlayersOfCountry] = []
class PlayersOfCountry:
	var game_players: Array[GamePlayer] = []

@onready var _margin_container := %MarginContainer as Control
@onready var _element_container := %ElementContainer as Control


func _ready() -> void:
	_set_margin_offsets()
	_refresh_list()

	get_viewport().size_changed.connect(_refresh_node_size)


func _refresh_list() -> void:
	if not is_node_ready():
		return

	NodeUtils.delete_all_children(_element_container)
	_element_nodes.clear()
	_players_of_country.clear()

	if countries == null or players == null:
		return

	# Initialize _players_of_country
	for country in countries.list():
		_players_of_country.append(PlayersOfCountry.new())

	# Populate _players_of_country with players
	for player in players.list():
		if player.is_spectating():
			continue
		_players_of_country[
				countries.position_of(player.playing_country.id)
		].game_players.append(player)

	# Create elements in country order
	for item in _players_of_country:
		for player in item.game_players:
			_add_element(player)

	_refresh_node_size()
	_update_elements()


## Leave position_index to -1 to add it to the end of the list
func _add_element(player: GamePlayer, position_index: int = -1) -> void:
	player.human_status_changed.connect(_on_human_status_changed)
	if player and player.is_human and player.player_human:
		player.player_human.sync_finished.connect(_update_elements)

	var element := _ELEMENT_SCENE.instantiate() as TurnOrderElement
	element.delete_pressed.connect(_on_element_delete_pressed)
	element.new_player_requested.connect(new_human_player_requested.emit)
	element.player = player
	element.init()
	element.turn = game_turn
	_element_nodes[player] = element
	_element_container.add_child(element)
	_element_container.move_child(element, position_index)


func _remove_element(player: GamePlayer) -> void:
	NodeUtils.delete_node(_element_nodes[player])
	_element_nodes.erase(player)


func _set_margin_offsets() -> void:
	_margin_container.offset_left = margin_pixels
	_margin_container.offset_right = -margin_pixels
	_margin_container.offset_top = margin_pixels
	_margin_container.offset_bottom = -margin_pixels


## Manually sets this node's size.
## Edits the value of [code]offset_bottom[/code] as well as the anchors.
## No effect if [code]is_shrunk[/code] is set to false.
func _refresh_node_size() -> void:
	if not is_shrunk:
		return

	const _SEPARATION: int = 4
	var new_size: int = 0
	for player in _element_nodes:
		new_size += roundi(_element_nodes[player].size.y) + _SEPARATION
	if new_size > 0:
		new_size -= _SEPARATION

	anchors_preset = PRESET_TOP_WIDE
	offset_bottom = new_size + margin_pixels * 2
	if get_parent_control() != null:
		offset_bottom = minf(offset_bottom, get_parent_control().size.y)


## Lets elements know if they're the only local human player.
## Prevents the user from deleting the only local human player.
func _update_elements(_player: Player = null) -> void:
	var is_the_only_local_human: bool = players.number_of_local_humans() == 1
	for player in _element_nodes:
		var human: Player = player.player_human
		var element: TurnOrderElement = _element_nodes[player]
		if player.is_human and not (human and human.is_remote()):
			element.is_the_only_local_human = is_the_only_local_human
		else:
			element.is_the_only_local_human = false


func _on_element_delete_pressed(game_player: GamePlayer) -> void:
	if not game_player.is_human or game_player.player_human == null:
		return
	player_removal_requested.emit(game_player.player_human)


func _on_country_added(country: Country) -> void:
	_players_of_country.insert(
			countries.position_of(country.id), PlayersOfCountry.new()
	)


func _on_country_removed(_country: Country) -> void:
	# There's no way to know what the country's index was...
	# So we gotta search for it.
	for i in _players_of_country.size():
		var players_i: Array[GamePlayer] = _players_of_country[i].game_players
		if players_i.is_empty() or players_i[0].playing_country != null:
			continue

		for player in players_i:
			_remove_element(player)

		_players_of_country.remove_at(i)

		_refresh_node_size()
		_update_elements()
		return


func _on_order_changed(
		_country_id: int, old_index: int, new_index: int
) -> void:
	var _players_to_move: PlayersOfCountry = (
			_players_of_country.pop_at(old_index)
	)
	_players_of_country.insert(new_index, _players_to_move)

	# Determine where the moved elements go
	var new_element_index: int = 0
	for i in _players_of_country.size():
		if i == new_index:
			break
		else:
			new_element_index += _players_of_country[i].game_players.size()

	for player in _element_nodes:
		if player in _players_to_move.game_players:
			_element_container.move_child(
					_element_nodes[player], new_element_index
			)
			new_element_index += 1


func _on_player_added(player: GamePlayer, _player_index: int) -> void:
	if player.is_spectating():
		return

	# Determine where this new player goes in country order
	var position_index: int = 0
	var new_player_country_index: int = (
			countries.position_of(player.playing_country.id)
	)
	for i in _players_of_country.size():
		position_index += _players_of_country[i].game_players.size()
		if i == new_player_country_index:
			_players_of_country[i].game_players.append(player)
			break

	_add_element(player, position_index)
	_refresh_node_size()
	_update_elements()


func _on_player_removed(player: GamePlayer) -> void:
	# Remove this player from country order
	_players_of_country[
			countries.position_of(player.playing_country.id)
	].game_players.erase(player)

	_remove_element(player)
	_refresh_node_size()
	_update_elements()


## When a player is turned into a human,
## we want the remove button to start appearing again on humans
func _on_human_status_changed(game_player: GamePlayer) -> void:
	# We are possibly dealing with a new [Player] instance,
	# so we need to connect signals.
	if (
			game_player.is_human
			and game_player.player_human != null
			and not game_player.player_human.sync_finished.is_connected(
					_update_elements
			)
	):
		game_player.player_human.sync_finished.connect(_update_elements)

	_update_elements()
