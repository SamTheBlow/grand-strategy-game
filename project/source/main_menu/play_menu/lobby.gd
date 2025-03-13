class_name Lobby
extends Control
## The menu from which you choose a game and its rules,
## add/join players, and start the game.
##
## Emits a signal when the user requests to start the game.
##
## Don't forget to inject the [Players] and the [GameRules] into their
## respective properties before adding this node to the scene tree.

signal start_game_requested(metadata: GameMetadata, game_rules: GameRules)

var players: Players:
	set(value):
		players = value
		_setup_players()

var game_menu_state: GameSelectMenuState:
	set(value):
		game_menu_state = value
		_setup_game_menu_state()

var game_rules: GameRules:
	set(value):
		game_rules = value
		_setup_game_rules()

var networking_interface: NetworkingInterface:
	set(value):
		networking_interface = value
		_setup_networking_interface()

@onready var _player_list := %PlayerList as PlayerList
@onready var _games_interface := %Games as GameSelectionMenu
@onready var _rules_interface := %Rules as RulesMenu
@onready var _menu_disabled_node := %MenuDisabled as Control
@onready var _start_button := %StartButton as Button


func _ready() -> void:
	_setup_players()
	_setup_game_menu_state()
	_setup_game_rules()
	_setup_networking_interface()

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	_update_menu_disabled()
	_update_start_button_disabled()


func _setup_players() -> void:
	if not is_node_ready():
		return

	_player_list.players = players


func _setup_game_menu_state() -> void:
	if not is_node_ready():
		return

	_games_interface.game_menu_state = game_menu_state


func _setup_game_rules() -> void:
	if not is_node_ready() or game_rules == null:
		return

	_rules_interface.game_rules = game_rules


func _setup_networking_interface() -> void:
	if not is_node_ready():
		return

	_player_list.networking_interface = networking_interface


## When connected to an online game,
## only the server is allowed to make changes to the rules.
func _update_menu_disabled() -> void:
	_menu_disabled_node.visible = (
			not MultiplayerUtils.has_authority(multiplayer)
	)


## When connected to an online game,
## only the server is allowed to start the game.
func _update_start_button_disabled() -> void:
	if MultiplayerUtils.is_online(multiplayer):
		_start_button.disabled = not multiplayer.is_server()
	else:
		_start_button.disabled = false


func _on_start_button_pressed() -> void:
	var metadata: GameMetadata = _games_interface.selected_game()
	start_game_requested.emit(metadata, game_rules)


func _on_connected_to_server() -> void:
	_update_menu_disabled()
	_update_start_button_disabled()


func _on_server_disconnected() -> void:
	_update_menu_disabled()
	_update_start_button_disabled()
