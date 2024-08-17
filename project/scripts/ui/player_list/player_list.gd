@tool
class_name PlayerList
extends Control
## Class responsible for displaying a list of [Player]s.
## It shows all players by their username.
## The user, when allowed, can add, remove and rename players.
## [br][br]
## This list can also include a [NetworkingInterface] at the bottom.
## To include one, use [method PlayerList.use_networking_interface].


@export_category("References")
@export var player_list_element: PackedScene
@export var margin: Control
@export var container: Control
@export var add_player_button: Control
@export var spacing: Control
@export var networking_setup: Control

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

## If the given [Players] object does not contain any human player,
## a new human player will be added automatically.
## This cannot be prevented: there must always be at least one human player.
var players: Players:
	set(value):
		if players:
			players.player_added.disconnect(_on_player_added)
			players.player_removed.disconnect(_on_player_removed)
			_clear_elements()
		
		players = value
		_create_elements()
		players.player_added.connect(_on_player_added)
		players.player_removed.connect(_on_player_removed)
		
		if players.size() == 0:
			_add_human_player()

var _is_using_network_interface: bool = false:
	set(value):
		_is_using_network_interface = value
		_update_networking_interface_visibility()
		_update_size()

var _visual_players: Array[PlayerListElement] = []

@onready var _add_player_root := %AddPlayerRoot as Control


func _ready() -> void:
	if not players:
		players = Players.new()
	_update_networking_interface_visibility()
	_update_margin_offsets()
	_update_size()
	get_viewport().size_changed.connect(_on_viewport_size_changed)


## If you don't want to use one, use [code]null[/code] as the input.
func use_networking_interface(
		networking_interface: NetworkingInterface
) -> void:
	# Remove all children
	for child in networking_setup.get_children():
		networking_setup.remove_child(child)
	
	if not networking_interface:
		_is_using_network_interface = false
		return
	
	networking_interface.interface_changed.connect(
			_on_networking_interface_changed
	)
	networking_setup.add_child(networking_interface)
	_is_using_network_interface = true


func _update_networking_interface_visibility() -> void:
	spacing.visible = _is_using_network_interface
	networking_setup.visible = _is_using_network_interface


func _add_element(player: Player) -> void:
	player.deletion_requested.connect(_on_player_deletion_requested)
	player.sync_finished.connect(_on_player_sync_finished)
	
	var element := player_list_element.instantiate() as PlayerListElement
	element.player = player
	element.init()
	_visual_players.append(element)
	container.add_child(element)
	container.move_child(element, -2)


func _create_elements() -> void:
	for player in players.list():
		_add_element(player)
	_update_elements()


func _remove_element(player: Player) -> void:
	player.deletion_requested.disconnect(_on_player_deletion_requested)
	
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
	if not margin:
		return
	
	margin.offset_left = margin_pixels
	margin.offset_right = -margin_pixels
	margin.offset_top = margin_pixels
	margin.offset_bottom = -margin_pixels


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
	
	# Add the size of the add button, when it's there
	if _add_player_root.visible:
		new_size += roundi(_add_player_root.size.y) + 4
	
	# Add the size of the server setup, when it's there
	if networking_setup.visible:
		new_size += 8 + 4
		new_size += roundi(networking_setup.custom_minimum_size.y) + 4
	
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
		if not element.player.is_remote():
			element.is_the_only_local_human = is_the_only_local_human
		else:
			element.is_the_only_local_human = false


func _add_human_player() -> void:
	players.add_local_human_player()


func _on_viewport_size_changed() -> void:
	_update_size()


func _on_player_deletion_requested(player: Player) -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		return
	
	if players.size() == 1:
		push_warning("Tried to remove the last player. Ignoring request.")
		return
	
	# Removing their last player? Kick them from the server
	if players.number_of_humans_with_multiplayer_id(player.multiplayer_id) < 2:
		players.kick_player(player)
		return
	
	# Remove the player
	players.remove_player(player)


func _on_add_player_button_pressed() -> void:
	_add_human_player()


func _on_networking_interface_changed() -> void:
	networking_setup.custom_minimum_size = (
			(networking_setup.get_child(0) as Control).custom_minimum_size
	)


func _on_player_added(player: Player) -> void:
	_add_element(player)
	_update_size()
	_update_elements()


func _on_player_removed(player: Player) -> void:
	_remove_element(player)
	_update_size()
	_update_elements()


func _on_player_sync_finished(_player: Player) -> void:
	_update_elements()
