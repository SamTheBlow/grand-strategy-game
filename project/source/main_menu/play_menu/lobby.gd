class_name Lobby
extends Control
## The menu from which you choose a game, add/join players, and start the game.
##
## Emits a signal when the user requests to start the game.

signal start_game_requested(file_path: String, rng_seed: String)

var game_menu_state: GameSelectMenuState:
	set(value):
		game_menu_state = value
		if is_node_ready():
			_refresh_games()

var players: Players:
	set(value):
		players = value
		if is_node_ready():
			_refresh_players()

var networking_interface: NetworkingInterface:
	set(value):
		networking_interface = value
		if is_node_ready():
			_refresh_networking_interface()

@onready var _seed_input := %SeedInput as LineEdit
@onready var _games_interface := %Games as GameSelectionMenu
@onready var _menu_disabled_node := %MenuDisabled as Control
@onready var _player_list := %PlayerList as PlayerList
@onready var _start_button := %StartButton as Button


func _ready() -> void:
	_refresh_games()
	_refresh_players()
	_refresh_networking_interface()

	_refresh_menu_disabled()
	_refresh_start_button_disabled()
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _refresh_games() -> void:
	_games_interface.game_menu_state = game_menu_state


func _refresh_players() -> void:
	_player_list.players = players


func _refresh_networking_interface() -> void:
	_player_list.networking_interface = networking_interface


## When connected to an online game, only the host is allowed to make changes.
func _refresh_menu_disabled() -> void:
	_menu_disabled_node.visible = (
			not MultiplayerUtils.has_authority(multiplayer)
	)


## When connected to an online game, only the host is allowed to start the game.
func _refresh_start_button_disabled() -> void:
	if MultiplayerUtils.is_online(multiplayer):
		_start_button.disabled = not multiplayer.is_server()
	else:
		_start_button.disabled = false


func _on_start_button_pressed() -> void:
	start_game_requested.emit(
			_games_interface.selected_game().project_absolute_path,
			_seed_input.text
	)


func _on_connected_to_server() -> void:
	_refresh_menu_disabled()
	_refresh_start_button_disabled()


func _on_server_disconnected() -> void:
	_refresh_menu_disabled()
	_refresh_start_button_disabled()
