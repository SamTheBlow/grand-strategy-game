class_name Lobby
extends Control
## The menu from which you choose the game's rules,
## add/join players, and start the game.
##
## Emits a signal when the user requests to start the game.
##
## Don't forget to inject the [Players] and the [GameRules] into their
## respective properties before adding this node to the scene tree.


signal start_game_requested(scenario: PackedScene)

@export var scenario_scene: PackedScene

var players: Players
var game_rules: GameRules

@onready var _player_list := %PlayerList as PlayerList
@onready var _rules_interface := %Rules as RuleRootNode
@onready var _rules_disabled_node := %RulesDisabled as Control
@onready var _start_button := %StartButton as Button


func _ready() -> void:
	if players:
		_player_list.players = players
	else:
		push_error("Players were not injected in the lobby.")
	
	if game_rules:
		_rules_interface.game_rules = game_rules
	else:
		push_error("Game rules were not injected in the lobby.")
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	_update_rules_disabled()
	_update_start_button_disabled()


func setup_networking_interface(interface: NetworkingInterface) -> void:
	(%PlayerList as PlayerList).use_networking_interface(interface)


## When connected to an online game,
## only the server is allowed to make changes to the rules.
func _update_rules_disabled() -> void:
	if MultiplayerUtils.is_online(multiplayer):
		_rules_disabled_node.visible = not multiplayer.is_server()
	else:
		_rules_disabled_node.visible = false


## When connected to an online game,
## only the server is allowed to start the game.
func _update_start_button_disabled() -> void:
	if MultiplayerUtils.is_online(multiplayer):
		_start_button.disabled = not multiplayer.is_server()
	else:
		_start_button.disabled = false


func _on_start_button_pressed() -> void:
	start_game_requested.emit(scenario_scene)


func _on_connected_to_server() -> void:
	_update_rules_disabled()
	_update_start_button_disabled()


func _on_server_disconnected() -> void:
	_update_rules_disabled()
	_update_start_button_disabled()
