@tool
class_name PlayerList
extends Control
## Class responsible for displaying a list of players.
## It shows all players by their username.
## During a game, it also shows with an arrow who's turn it is to play.


@export_category("References")
@export var player_list_element: PackedScene
@export var margin: Control
@export var container: Control
@export var add_player_button: Control
@export var server_setup: Control

@export_category("Variables")

## If true, the player list shrinks down to the size of the contents.
## If false, it uses the given position/anchors as usual.
## Do not change this while the game is running.
@export var is_shrunk: bool = true:
	set(value):
		is_shrunk = value
		_update_size()

## The number of pixels that separate the list's contents from the edges.
@export var margin_pixels: int = 16:
	set(value):
		margin_pixels = value
		_update_margin_offsets()
		_update_size()

var _players: Players
var _is_discarding_ai_players: bool = false
var _visual_players: Array[PlayerListElement] = []


func _ready() -> void:
	_update_margin_offsets()
	_update_size()
	get_viewport().size_changed.connect(_on_viewport_size_changed)


## To be called when this node is created.
func init(player_list: Array[Player], game_turn: GameTurn = null) -> void:
	_players = Players.new()
	_players.players = player_list.duplicate()
	
	## TODO make a better way to know if we're in lobby or in game
	_is_discarding_ai_players = true
	if game_turn:
		add_player_button.hide()
		_is_discarding_ai_players = false
	
	for i in _players.players.size():
		_add_element(_players.players[i], game_turn)
	
	_update_elements()
	_update_size()


## Returns a copy of this list's players
func players() -> Players:
	var copy := Players.new()
	copy.players = _players.players.duplicate()
	return copy


func _add_element(player: Player, game_turn: GameTurn = null) -> void:
	player.human_status_changed.connect(_on_human_status_changed)
	
	var element := player_list_element.instantiate() as PlayerListElement
	element.init(player)
	if game_turn:
		element.init_turn(game_turn)
	_visual_players.append(element)
	container.add_child(element)
	container.move_child(element, -2)


## To be called when the margin_pixels property changes.
func _update_margin_offsets() -> void:
	margin.offset_left = margin_pixels
	margin.offset_right = -margin_pixels
	margin.offset_top = margin_pixels
	margin.offset_bottom = -margin_pixels


## Manually sets this node's size.
## Edits the value of [code]offset_bottom[/code] as well as the anchors.
## Call this whenever any child node's vertical size changes.
## This function has no effect when [code]is_shrunk[/code] is set to false.
func _update_size() -> void:
	if not is_shrunk:
		return
	
	var new_size: int = 0
	for child in container.get_children():
		if not child is PlayerListElement:
			continue
		new_size += roundi((child as PlayerListElement).size.y)
		
		# I really don't know why we need to add 4, but it just works
		new_size += 4
	
	# Add the size of the add button, when it's there
	if add_player_button.visible:
		new_size += roundi(add_player_button.size.y) + 4
	
	# Add the size of the server setup, when it's there
	if server_setup.visible:
		new_size += roundi(server_setup.custom_minimum_size.y)
	
	anchors_preset = PRESET_TOP_WIDE
	offset_bottom = new_size + margin_pixels * 2
	if get_parent_control():
		offset_bottom = minf(offset_bottom, get_parent_control().size.y)


## To be called whenever the number of human players changes
func _update_elements() -> void:
	for element in _visual_players:
		element.is_the_only_human = _players.number_of_humans() == 1


func _on_viewport_size_changed() -> void:
	_update_size()


func _on_human_status_changed(player: Player) -> void:
	if (not _is_discarding_ai_players) or player.is_human:
		_update_elements()
		return
	if _players.players.size() == 1:
		print_debug(
				"Tried to remove a human player, but"
				+ " there is already only one human player!"
		)
		_update_elements()
		return
	
	# The player became an AI. Discard this player
	player.human_status_changed.disconnect(_on_human_status_changed)
	var index: int = _players.players.find(player)
	_visual_players[index].get_parent().remove_child(_visual_players[index])
	_visual_players[index].queue_free()
	_visual_players.remove_at(index)
	_players.players.remove_at(index)
	
	## TODO don't hard code the maximum number of players
	if _players.players.size() < 11:
		add_player_button.show()
	
	_update_elements()


func _on_add_player_button_pressed() -> void:
	var player := Player.new()
	player.is_human = true
	player.custom_username = _players.new_default_username()
	
	_players.add_player(player)
	## TODO don't hard code the maximum number of players
	if _players.players.size() >= 11:
		add_player_button.hide()
	
	_add_element(player)
	_update_elements()
