class_name MainMenu
extends Node
## The scene that the user enters by default.
## Currently only contains the [Lobby] and an interface for the [Chat].


signal game_started(scenario: PackedScene)

@export var networking_setup_scene: PackedScene

var _chat: Chat


func _ready() -> void:
	# TODO the networking setup stuff is ugly I think, shouldn't be here
	var networking_setup := (
			networking_setup_scene.instantiate() as NetworkingInterface
	)
	networking_setup.message_sent.connect(
			_chat._on_networking_interface_message_sent
	)
	(%Lobby as Lobby).setup_networking_interface(networking_setup)


## Dependency injection
func setup_players(players: Players) -> void:
	(%Lobby as Lobby).players = players


## Dependency injection
func setup_rules(game_rules: GameRules) -> void:
	(%Lobby as Lobby).game_rules = game_rules


## Dependency injection
func setup_chat(chat: Chat) -> void:
	_chat = chat
	var chat_interface := %ChatInterface as ChatInterface
	chat_interface.chat_data = chat.chat_data
	chat.connect_chat_interface(chat_interface)


func _on_start_game_requested(scenario: PackedScene) -> void:
	game_started.emit(scenario)
