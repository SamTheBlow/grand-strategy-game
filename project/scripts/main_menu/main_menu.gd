class_name MainMenu
extends Node


signal game_started(scenario: PackedScene, rules: GameRules)

@export var networking_setup_scene: PackedScene

@onready var _lobby := %Lobby as Lobby
@onready var _chat := %Chat as Chat


func _ready() -> void:
	var networking_setup := (
			networking_setup_scene.instantiate() as NetworkingInterface
	)
	networking_setup.message_sent.connect(
			_chat._on_networking_interface_message_sent
	)
	_lobby.player_list.use_networking_interface(networking_setup)


## Dependency injection: passes the players node to the player list.
func setup_players(players: Players) -> void:
	(%Lobby as Lobby).player_list.players = players


## Dependency injection: passes the chat data to the chat interface.
func setup_chat_data(chat_data: ChatData) -> void:
	(%Chat as Chat).chat_data = chat_data


func _on_start_game_requested(scenario: PackedScene, rules: GameRules) -> void:
	game_started.emit(scenario, rules)
