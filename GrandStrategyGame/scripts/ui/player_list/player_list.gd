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

@export_category("Variables")
@export var margin_pixels: int = 16 : set = _set_margin_pixels

var _players: Players


func _ready() -> void:
	_set_margin_pixels(margin_pixels)
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _on_viewport_size_changed() -> void:
	_update_size()


func _on_add_player_button_pressed() -> void:
	var player := Player.new()
	player.is_human = true
	player.default_username = _players.new_default_username()
	
	_players.players.append(player)
	## TODO don't hard code the maximum number of players
	if _players.players.size() >= 11:
		add_player_button.hide()
	
	_add_element(player)


## To be called when this node is created.
func init(players: Array[Player], game_turn: GameTurn = null) -> void:
	_players = Players.new()
	_players.players = players.duplicate()
	
	if game_turn:
		add_player_button.hide()
	
	for i in players.size():
		_add_element(players[i], game_turn)
	
	_update_size()


func _set_margin_pixels(value: int) -> void:
	margin_pixels = value
	margin.offset_left = margin_pixels
	margin.offset_right = -margin_pixels
	margin.offset_top = margin_pixels
	margin.offset_bottom = -margin_pixels
	_update_size()


func _add_element(player: Player, game_turn: GameTurn = null) -> void:
	var element := player_list_element.instantiate() as PlayerListElement
	element.init(player)
	if game_turn:
		element.init_turn(game_turn)
	container.add_child(element)
	container.move_child(element, -2)


## Manually set this node's size
func _update_size() -> void:
	var new_size: int = 0
	for child in container.get_children():
		if not child is PlayerListElement:
			continue
		new_size += roundi((child as PlayerListElement).size.y)
		
		# I really don't know why we need to add 4, but it just works
		new_size += 4
	
	offset_bottom = new_size + margin_pixels * 2
	if get_parent_control():
		offset_bottom = minf(offset_bottom, get_parent_control().size.y)
