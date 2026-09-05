@tool
class_name PlayerList
extends Control
## Displays a list of [Players] and a [NetworkingInterface].
## Allows the user to add, remove and rename players when applicable.
## Allows the user to host a server and disconnect from a server.

## Emitted on the server when a new player is added
## as a result of pressing "Add Player".
signal player_added(player: Player)

const _ELEMENT_SCENE: PackedScene = preload("uid://75dgexs1e3no")

## If true, the player list shrinks down to the size of the contents.
## If false, it uses the given position/anchors as usual.
## Please do not change this value while the game is running.
@export var is_shrunk: bool = true:
	set(value):
		is_shrunk = value
		_refresh_node_size()

## The number of pixels that separate the list's contents from the edges.
@export var margin_pixels: int = 16:
	set(value):
		margin_pixels = value
		if is_node_ready():
			_refresh_margin_offsets()
			_refresh_node_size()

var players: Players:
	set(value):
		if players != null:
			players.player_added.disconnect(_on_player_added)
			players.player_removed.disconnect(_on_player_removed)

		players = value
		if is_node_ready():
			_refresh_list()

		players.player_added.connect(_on_player_added)
		players.player_removed.connect(_on_player_removed)

var _element_nodes: Dictionary[Player, PlayerListElement] = {}

@onready var networking_interface := %NetworkingInterface as NetworkingInterface

@onready var _margin := %MarginContainer as Control
@onready var _container := %ElementContainer as Control
@onready var _add_player_root := %AddPlayerRoot as Control


func _ready() -> void:
	if players == null:
		players = Players.new()

	_refresh_margin_offsets()
	_refresh_list()

	get_viewport().size_changed.connect(_refresh_node_size)


func hide_networking() -> void:
	networking_interface.hide()
	_refresh_node_size()


func _add_element(player: Player) -> void:
	player.sync_finished.connect(_refresh_elements.unbind(1))

	var element := _ELEMENT_SCENE.instantiate() as PlayerListElement
	element.delete_pressed.connect(_on_element_delete_pressed)
	element.player = player
	element.init()
	_element_nodes[player] = element
	_container.add_child(element)
	_container.move_child(element, -2)


func _remove_element(player: Player) -> void:
	NodeUtils.delete_node(_element_nodes[player])
	_element_nodes.erase(player)

	player.sync_finished.disconnect(_refresh_elements)


## Sets the margin node's offsets according to the margin_pixels property.
func _refresh_margin_offsets() -> void:
	_margin.offset_left = margin_pixels
	_margin.offset_right = -margin_pixels
	_margin.offset_top = margin_pixels
	_margin.offset_bottom = -margin_pixels


func _refresh_list() -> void:
	for player in _element_nodes:
		NodeUtils.delete_node(_element_nodes[player])
		player.sync_finished.disconnect(_refresh_elements)
	_element_nodes.clear()

	for player in players.list():
		_add_element(player)

	_refresh_node_size()
	_refresh_elements()


## Manually sets this node's size.
## Edits the value of [code]offset_bottom[/code] as well as the anchors.
## Call this whenever any child node's vertical size changes.
## This function has no effect when [code]is_shrunk[/code] is set to false.
func _refresh_node_size() -> void:
	if not is_node_ready() or not is_shrunk:
		return

	# Sum up the size of each element (including separation)
	var new_size: int = 0
	for element: PlayerListElement in _element_nodes.values():
		new_size += roundi(element.size.y) + 4

	# Add the size of the add button, when it's there
	if _add_player_root.visible:
		new_size += roundi(_add_player_root.size.y) + 4

	if new_size > 0:
		new_size -= 4

	# Add the size of the networking interface, when it's there
	if networking_interface.visible:
		new_size += 16 + roundi(networking_interface.custom_minimum_size.y)

	anchors_preset = PRESET_TOP_WIDE
	offset_bottom = new_size + margin_pixels * 2
	if get_parent_control() != null:
		offset_bottom = minf(offset_bottom, get_parent_control().size.y)


## Tells all elements whether or not they are the only local player,
## in which case they must not allow deleting that player.
func _refresh_elements() -> void:
	var is_the_only_local_human: bool = players.number_of_local_players() == 1
	for player in _element_nodes:
		_element_nodes[player].is_the_only_local_human = (
				false if player.is_remote() else is_the_only_local_human
		)


func _add_new_player(multiplayer_id: int = 1) -> void:
	var new_player: Player = players.new_player(multiplayer_id)
	players.add_player(new_player)
	player_added.emit(new_player)


## The server adds a new player owned by the sender client.
@rpc("any_peer", "call_remote", "reliable")
func _add_new_remote_player() -> void:
	_add_new_player(multiplayer.get_remote_sender_id())


func _on_element_delete_pressed(player: Player) -> void:
	if players.size() == 1:
		push_warning("Tried to remove the last player. Ignoring request.")
		return

	players.remove_player(player)


func _on_add_player_button_pressed() -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		_add_new_player()
	else:
		_add_new_remote_player.rpc_id(1)


func _on_player_added(player: Player) -> void:
	_add_element(player)
	_refresh_node_size()
	_refresh_elements()


func _on_player_removed(player: Player) -> void:
	_remove_element(player)
	_refresh_node_size()
	_refresh_elements()
