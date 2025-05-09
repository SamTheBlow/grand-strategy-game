@tool
class_name PlayerList
extends Control
## Class responsible for displaying a list of [Player]s.
## It shows all players by their username.
## The user, when allowed, can add, remove and rename players.
## Optionally, this list can also include a [NetworkingInterface] at the bottom.

## Emitted on the server when a new player is added
## as a result of pressing "Add Player".
signal player_added(player: Player)

## The scene's root node must extend [PlayerListElement].
@export var _player_list_element_scene: PackedScene

## Optional. When set, adds this interface at the bottom of the list.
@export var networking_interface: NetworkingInterface:
	set(value):
		_disconnect_signals()
		networking_interface = value
		_connect_signals()
		_setup_networking_interface()
		_update_size()

## If true, the player list shrinks down to the size of the contents.
## If false, it uses the given position/anchors as usual.
## Please do not change this value while the game is running.
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

var players: Players:
	set(value):
		if players != null:
			players.player_added.disconnect(_on_player_added)
			players.player_removed.disconnect(_on_player_removed)
			_clear_elements()

		players = value

		if players == null:
			return

		_create_elements()
		players.player_added.connect(_on_player_added)
		players.player_removed.connect(_on_player_removed)

var _visual_players: Array[PlayerListElement] = []

@onready var _margin := %MarginContainer as Control
@onready var _container := %ElementContainer as Control
@onready var _add_player_root := %AddPlayerRoot as Control

@onready var _spacing := %Spacing as Control
@onready var _networking_setup := %NetworkingSetup as Control


func _ready() -> void:
	if players == null:
		players = Players.new()

	_setup_networking_interface()
	_update_margin_offsets()
	_update_size()

	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _setup_networking_interface() -> void:
	if not is_node_ready():
		return

	NodeUtils.delete_all_children(_networking_setup)

	# Show/hide nodes
	var node_exists: bool = networking_interface != null
	_spacing.visible = node_exists
	_networking_setup.visible = node_exists

	# Add child
	if node_exists:
		_networking_setup.add_child(networking_interface)


func _disconnect_signals() -> void:
	if networking_interface == null:
		return

	if (
			networking_interface.interface_changed
			.is_connected(_on_networking_interface_changed)
	):
		networking_interface.interface_changed.disconnect(
				_on_networking_interface_changed
		)


func _connect_signals() -> void:
	if networking_interface == null:
		return

	if not (
			networking_interface.interface_changed
			.is_connected(_on_networking_interface_changed)
	):
		networking_interface.interface_changed.connect(
				_on_networking_interface_changed
		)


func _add_element(player: Player) -> void:
	player.sync_finished.connect(_on_player_sync_finished)

	var element := _player_list_element_scene.instantiate() as PlayerListElement
	element.player = player
	element.init()
	element.delete_pressed.connect(_on_element_delete_pressed)
	_visual_players.append(element)
	_container.add_child(element)
	_container.move_child(element, -2)


func _create_elements() -> void:
	for player in players.list():
		_add_element(player)

	_update_size()
	_update_elements()


func _remove_element(player: Player) -> void:
	for visual in _visual_players:
		if visual.player == player:
			visual.get_parent().remove_child(visual)
			visual.queue_free()
			_visual_players.erase(visual)
			break


func _clear_elements() -> void:
	NodeUtils.delete_nodes(_visual_players)
	_visual_players.clear()


## Updates the margin node according to the margin_pixels property.
func _update_margin_offsets() -> void:
	if not is_node_ready():
		return

	_margin.offset_left = margin_pixels
	_margin.offset_right = -margin_pixels
	_margin.offset_top = margin_pixels
	_margin.offset_bottom = -margin_pixels


## Manually sets this node's size.
## Edits the value of [code]offset_bottom[/code] as well as the anchors.
## Call this whenever any child node's vertical size changes.
## This function has no effect when [code]is_shrunk[/code] is set to false.
func _update_size() -> void:
	if not is_node_ready() or not is_shrunk:
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
	if _networking_setup.visible:
		new_size += 8 + 4
		new_size += roundi(_networking_setup.custom_minimum_size.y) + 4

	if new_size > 0:
		new_size -= 4

	anchors_preset = PRESET_TOP_WIDE
	offset_bottom = new_size + margin_pixels * 2
	if get_parent_control():
		offset_bottom = minf(offset_bottom, get_parent_control().size.y)


## To be called whenever the number of local human players changes
func _update_elements() -> void:
	var is_the_only_local_human: bool = players.number_of_local_players() == 1
	for element in _visual_players:
		if not element.player.is_remote():
			element.is_the_only_local_human = is_the_only_local_human
		else:
			element.is_the_only_local_human = false


func _add_new_player(multiplayer_id: int = 1) -> void:
	var new_player: Player = players.new_player(multiplayer_id)
	players.add_player(new_player)
	player_added.emit(new_player)


## The server receives a client's request to add a new local player.
@rpc("any_peer", "call_remote", "reliable")
func _receive_add_new_player() -> void:
	_add_new_player(multiplayer.get_remote_sender_id())


func _on_viewport_size_changed() -> void:
	_update_size()


func _on_element_delete_pressed(player: Player) -> void:
	if players.size() == 1:
		push_warning("Tried to remove the last player. Ignoring request.")
		return

	players.remove_player(player)


func _on_add_player_button_pressed() -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		_add_new_player()
	else:
		_receive_add_new_player.rpc_id(1)


func _on_networking_interface_changed() -> void:
	_networking_setup.custom_minimum_size = (
			(_networking_setup.get_child(0) as Control).custom_minimum_size
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
