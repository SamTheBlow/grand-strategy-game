class_name MainMenu
extends Node
## The main menu.
## Currently only contains the [Lobby] and a [ChatInterface].


signal game_started(map_file_path: String, generation_settings: GameRules)

@export var networking_interface_scene: PackedScene

var _players: Players
var _game_rules: GameRules
var _chat: Chat

@onready var _lobby := %Lobby as Lobby
@onready var _chat_interface := %ChatInterface as ChatInterface


func _ready() -> void:
	# TODO this networking interface stuff is ugly I think, shouldn't be here
	# TODO bad code: private function
	var networking_interface := (
			networking_interface_scene.instantiate() as NetworkingInterface
	)
	networking_interface.message_sent.connect(
			_chat._on_networking_interface_message_sent
	)
	
	_chat_interface.chat_data = _chat.chat_data
	_chat.connect_chat_interface(_chat_interface)
	
	_lobby.players = _players
	_lobby.game_rules = _game_rules
	_lobby.networking_interface = networking_interface


## Dependency injection
func setup_players(players: Players) -> void:
	_players = players


## Dependency injection
func setup_rules(game_rules: GameRules) -> void:
	_game_rules = game_rules


## Dependency injection
func setup_chat(chat: Chat) -> void:
	_chat = chat


func _on_start_game_requested(
		map_file_path: String, generation_settings: GameRules
) -> void:
	game_started.emit(map_file_path, generation_settings)
