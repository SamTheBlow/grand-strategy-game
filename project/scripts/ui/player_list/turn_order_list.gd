@tool
class_name TurnOrderList
extends Control
## Class responsible for displaying a list of players in the
## turn order that they play. It shows all players by their username.
## It also shows with an arrow whose turn it is to play.
## Spectators are listed at the end of the list.


signal new_human_player_requested(game_player: GamePlayer)

@export var turn_order_element: PackedScene

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

var players: GamePlayers:
	set(value):
		if players:
			players.player_added.disconnect(_on_player_added)
			players.player_removed.disconnect(_on_player_removed)
			_clear_elements()
		
		players = value
		_create_elements()
		players.player_added.connect(_on_player_added)
		players.player_removed.connect(_on_player_removed)

## This value is designed to be only set once.
## To not use the game turn feature, leave this value to [code]null[/code].
var game_turn: GameTurn = null:
	set(value):
		game_turn = value
		
		for element in _visual_players:
			element.turn = game_turn

# A list of the PlayerContainer node's children, for convenience
var _visual_players: Array[TurnOrderElement] = []

var _margin_container: Control:
	get:
		if not _margin_container:
			_margin_container = $MarginContainer as Control
		return _margin_container

var _player_container: Control:
	get:
		if not _player_container:
			_player_container = %PlayerContainer as Control
		return _player_container


func _ready() -> void:
	_update_margin_offsets()
	_update_size()
	get_viewport().size_changed.connect(_on_viewport_size_changed)


# Leave position_index to -1 to add it to the end of the list
func _add_element(player: GamePlayer, position_index: int = -1) -> void:
	player.human_status_changed.connect(_on_human_status_changed)
	if player and player.is_human and player.player_human:
		player.player_human.sync_finished.connect(_on_player_sync_finished)
	
	var element := turn_order_element.instantiate() as TurnOrderElement
	element.new_player_requested.connect(_on_new_player_requested)
	element.player = player
	element.init()
	element.turn = game_turn
	_visual_players.append(element)
	_player_container.add_child(element)
	_player_container.move_child(element, position_index)


func _create_elements() -> void:
	for player in players.list():
		_add_element(player)
	_update_elements()


func _remove_element(player: GamePlayer) -> void:
	for visual in _visual_players:
		if visual.player == player:
			visual.get_parent().remove_child(visual)
			visual.queue_free()
			_visual_players.erase(visual)
			break


func _clear_elements() -> void:
	for element in _visual_players:
		element.get_parent().remove_child(element)
		element.queue_free()
	_visual_players.clear()


## To be called when the margin_pixels property changes.
func _update_margin_offsets() -> void:
	_margin_container.offset_left = margin_pixels
	_margin_container.offset_right = -margin_pixels
	_margin_container.offset_top = margin_pixels
	_margin_container.offset_bottom = -margin_pixels


## Manually sets this node's size.
## Edits the value of [code]offset_bottom[/code] as well as the anchors.
## Call this whenever any child node's vertical size changes.
## This function has no effect when [code]is_shrunk[/code] is set to false.
func _update_size() -> void:
	if not is_inside_tree() or not is_shrunk:
		return
	
	var new_size: int = 0
	for element in _visual_players:
		new_size += roundi(element.size.y)
		
		# Godot adds 4 pixels of spacing between each node
		new_size += 4
	
	if new_size > 0:
		new_size -= 4
	
	anchors_preset = PRESET_TOP_WIDE
	offset_bottom = new_size + margin_pixels * 2
	if get_parent_control():
		offset_bottom = minf(offset_bottom, get_parent_control().size.y)


## To be called whenever the number of local human players changes
func _update_elements() -> void:
	var is_the_only_local_human: bool = players.number_of_local_humans() == 1
	for element in _visual_players:
		var human: Player = element.player.player_human
		if element.player.is_human and not (human and human.is_remote()):
			element.is_the_only_local_human = is_the_only_local_human
		else:
			element.is_the_only_local_human = false


func _on_viewport_size_changed() -> void:
	_update_size()


func _on_player_added(player: GamePlayer, position_index: int) -> void:
	_add_element(player, position_index)
	_update_size()
	_update_elements()


func _on_player_removed(player: GamePlayer) -> void:
	_remove_element(player)
	_update_size()
	_update_elements()


func _on_player_sync_finished(_player: Player) -> void:
	_update_elements()


# When a player is turned into a human,
# we want the remove button to start appearing again on humans
func _on_human_status_changed(_player: GamePlayer) -> void:
	_update_elements()


func _on_new_player_requested(game_player: GamePlayer) -> void:
	new_human_player_requested.emit(game_player)
