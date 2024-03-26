@tool
class_name PlayerList
extends Control
## Class responsible for displaying a list of players.
## It shows all players by their username.
## During a game, it also shows with an arrow who's turn it is to play.
##
## This list can also include an interface for networking setup at the bottom.
## To include one, use the [code]use_networking_interface()[/code] function.


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

## If the given players object contains no human player,
## a new human player is added automatically.
## This cannot be prevented: there must always be at least one human player.
var players: Players:
	set(value):
		if players:
			players.player_added.disconnect(_on_player_added)
			players.player_removed.disconnect(_on_player_removed)
			_clear_elements()
		
		players = value
		
		if players.number_of_humans() == 0:
			_add_human_player()
		
		_create_elements()
		players.player_added.connect(_on_player_added)
		players.player_removed.connect(_on_player_removed)

## This value is designed to be only set once.
## To not use the game turn feature, leave this value to [code]null[/code].
var game_turn: GameTurn = null:
	set(value):
		game_turn = value
		
		## TODO make a better way to know if we're in lobby or in game
		if not game_turn:
			_is_discarding_ai_players = true
			return
		add_player_button.hide()
		_is_discarding_ai_players = false
		
		if not players:
			return
		for element in container.get_children():
			if element is PlayerListElement:
				(element as PlayerListElement).init_turn(game_turn)

var _is_discarding_ai_players: bool = true
var _visual_players: Array[PlayerListElement] = []


func _ready() -> void:
	if not players:
		players = Players.new()
	_update_margin_offsets()
	_update_size()
	get_viewport().size_changed.connect(_on_viewport_size_changed)


## To not use any networking interface, use [code]null[/code] as the input.
func use_networking_interface(
		networking_interface: NetworkingInterface
) -> void:
	# Remove all children
	for child in networking_setup.get_children():
		networking_setup.remove_child(child)
	
	if not networking_interface:
		spacing.hide()
		networking_setup.hide()
		return
	
	networking_interface.interface_changed.connect(
			_on_networking_interface_changed
	)
	spacing.show()
	networking_setup.show()
	networking_setup.add_child(networking_interface)


func _add_element(player: Player) -> void:
	player.human_status_changed.connect(_on_human_status_changed)
	
	var element := player_list_element.instantiate() as PlayerListElement
	element.player = player
	element.init()
	if game_turn:
		element.init_turn(game_turn)
	_visual_players.append(element)
	container.add_child(element)
	container.move_child(element, -2)


func _create_elements() -> void:
	for player in players.list():
		_add_element(player)
	_update_elements()


func _remove_element(player: Player) -> void:
	player.human_status_changed.disconnect(_on_human_status_changed)
	
	for visual in _visual_players:
		if visual.player == player:
			visual.get_parent().remove_child(visual)
			visual.queue_free()
			_visual_players.erase(visual)
			break


func _clear_elements() -> void:
	for element in container.get_children():
		if element is PlayerListElement:
			container.remove_child(element)
			element.queue_free()


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
	if networking_setup.visible:
		new_size += 8 + 4
		new_size += roundi(networking_setup.custom_minimum_size.y) + 4
	
	if new_size > 0:
		new_size -= 4
	
	anchors_preset = PRESET_TOP_WIDE
	offset_bottom = new_size + margin_pixels * 2
	if get_parent_control():
		offset_bottom = minf(offset_bottom, get_parent_control().size.y)


## To be called whenever the number of human players changes
func _update_elements() -> void:
	for element in _visual_players:
		element.is_the_only_human = players.number_of_humans() == 1


## Call this when you find out that
## the players list doesn't have any human player
func _add_human_player() -> void:
	var player: Player = Player.new()
	player.id = players.new_unique_id()
	player.is_human = true
	player.custom_username = players.new_default_username()
	players.add_player(player)


func _on_viewport_size_changed() -> void:
	_update_size()


func _on_human_status_changed(player: Player) -> void:
	if (not _is_discarding_ai_players) or player.is_human:
		_update_elements()
		return
	if players.number_of_humans() == 0:
		print_debug(
				"The last human player was turned into an AI!"
				+ " (That's not normal!)"
		)
		player.is_human = true
		_update_elements()
		return
	
	# The player became an AI. Discard this player
	players.remove_player(player)


func _on_add_player_button_pressed() -> void:
	var player := Player.new()
	player.is_human = true
	player.id = players.new_unique_id()
	player.custom_username = players.new_default_username()
	players.add_player(player)


func _on_networking_interface_changed() -> void:
	networking_setup.custom_minimum_size = (
			(networking_setup.get_child(0) as Control).custom_minimum_size
	)


func _on_player_added(player: Player) -> void:
	## TODO don't hard code the maximum number of players
	if players.size() >= 11:
		add_player_button.hide()
	
	_add_element(player)
	_update_elements()


func _on_player_removed(player: Player) -> void:
	## TODO don't hard code the maximum number of players
	if players.size() < 11:
		add_player_button.show()
	
	_remove_element(player)
	_update_elements()
	
	if players.number_of_humans() == 0:
		print_debug(
				"The last human player was removed from the list!"
				+ " (That's not normal!)"
		)
		_add_human_player()
