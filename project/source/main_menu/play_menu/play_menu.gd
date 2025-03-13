class_name PlayMenu
extends Node
## The menu that appears when clicking "Play" on the main menu.
## Contains the [Lobby] and a [ChatInterface].

signal game_started(game: Game)

@export var networking_interface_scene: PackedScene

var _players: Players
var _game_menu_state: GameSelectMenuState
var _game_rules: GameRules
var _chat: Chat

var _load_thread := Thread.new()
var _mutex := Mutex.new()
var _is_loading: bool = false

@onready var _lobby := %Lobby as Lobby
@onready var _chat_interface := %ChatInterface as ChatInterface
@onready var _loading_screen := %LoadingScreen as Control


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
	_lobby.game_menu_state = _game_menu_state
	_lobby.game_rules = _game_rules
	_lobby.networking_interface = networking_interface


func _exit_tree() -> void:
	if _load_thread.is_started():
		_load_thread.wait_to_finish()


## Dependency injection
func inject(
		players: Players,
		game_menu_state: GameSelectMenuState,
		game_rules: GameRules,
		chat: Chat,
) -> void:
	_players = players
	_game_menu_state = game_menu_state
	_game_rules = game_rules
	_chat = chat


## Called in a separate thread.
## Loads a new game, generates data if applicable and
## populates the data with given generation settings.
func _setup_game(metadata: GameMetadata, game_rules: GameRules) -> void:
	var generated_game := GameLoadGenerated.new()
	generated_game.load_game(metadata, game_rules)

	_mutex.lock()
	if not _is_loading:
		# Loading was cancelled.
		_mutex.unlock()
		return
	_mutex.unlock()

	if generated_game.error:
		_on_start_game_error.call_deferred(generated_game.error_message)
	else:
		_on_start_game_ready.call_deferred(generated_game.result)


## Called on the main thread when the other thread is done.
func _on_start_game_ready(game: Game) -> void:
	_mutex.lock()
	_is_loading = false
	_mutex.unlock()
	_loading_screen.visible = false

	game_started.emit(game)


## Called on the main thread when the other thread encounters an error.
func _on_start_game_error(error_message: String) -> void:
	_mutex.lock()
	_is_loading = false
	_mutex.unlock()
	_loading_screen.visible = false

	push_warning("Failed to load & setup game: ", error_message)
	_chat.send_system_message("Failed to load & setup the game")


func _on_start_game_requested(
		metadata: GameMetadata, generation_settings: GameRules
) -> void:
	if _load_thread.is_started():
		_load_thread.wait_to_finish()

	_mutex.lock()
	_is_loading = true
	_mutex.unlock()
	_loading_screen.visible = true

	_load_thread.start(_setup_game.bind(metadata, generation_settings))


## Called on the main thread when user presses the "Cancel" button.
func _on_start_game_cancelled() -> void:
	_mutex.lock()
	_is_loading = false
	_mutex.unlock()
	_loading_screen.visible = false
