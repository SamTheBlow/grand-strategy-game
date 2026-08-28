class_name PlayMenu
extends Node
## The menu that appears when clicking "Play" on the main menu.

signal exited()
signal game_started(project: GameProject)

@export var networking_interface_scene: PackedScene

var game_menu_state: GameSelectMenuState
var players: Players
var chat: Chat

var _load_thread := Thread.new()
var _mutex := Mutex.new()
var _is_loading: bool = false

@onready var _seed_input := %SeedInput as LineEdit
@onready var _games_interface := %Games as GameSelectionMenu
@onready var _player_list := %PlayerList as PlayerList
@onready var _chat_interface := %ChatInterface as ChatInterface
@onready var _loading_screen := %LoadingScreen as Control


func _ready() -> void:
	var networking_interface := (
			networking_interface_scene.instantiate() as NetworkingInterface
	)

	_chat_interface.chat_data = chat.chat_data
	chat.connect_chat_interface(_chat_interface)
	chat.connect_networking_interface(networking_interface)

	_games_interface.game_menu_state = game_menu_state
	_player_list.players = players
	_player_list.networking_interface = networking_interface


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		close()


func _exit_tree() -> void:
	if _load_thread.is_started():
		_load_thread.wait_to_finish()


func close() -> void:
	# Disconnect from online play
	multiplayer.multiplayer_peer.close()

	exited.emit()


## Called in a separate thread.
## Loads a game, overwrites its seed and ends its setup phase,
## potentially triggering game generation in the process.
func _setup_game(file_path: String, rng_seed: String) -> void:
	var parse_result: ProjectParsing.ParseResult = (
			ProjectFromPath.loaded_from(file_path)
	)

	_mutex.lock()
	if not _is_loading:
		# Loading was cancelled.
		_mutex.unlock()
		return
	_mutex.unlock()

	if parse_result.error:
		_on_start_game_error.call_deferred(parse_result.error_message)
	else:
		var project: GameProject = parse_result.result_project

		# Overwrite seed
		if (
				project.game.state == Game.GameState.SETUP
				and project.game.rng.rng_seed == ""
		):
			project.game.rng.rng_seed = rng_seed

		project.game.setup_for_play()
		_on_start_game_ready.call_deferred(project)


## Called on the main thread when the other thread is done.
func _on_start_game_ready(project: GameProject) -> void:
	_mutex.lock()
	_is_loading = false
	_mutex.unlock()
	_loading_screen.visible = false

	game_started.emit(project)


## Called on the main thread when the other thread encounters an error.
func _on_start_game_error(error_message: String) -> void:
	_mutex.lock()
	_is_loading = false
	_mutex.unlock()
	_loading_screen.visible = false

	push_warning("Failed to load & setup game: ", error_message)
	chat.send_system_message("Failed to load & setup the game")


func _on_start_button_pressed() -> void:
	if _load_thread.is_started():
		_load_thread.wait_to_finish()

	_mutex.lock()
	_is_loading = true
	_mutex.unlock()
	_loading_screen.visible = true

	_load_thread.start(_setup_game.bind(
			_games_interface.selected_game().project_absolute_path,
			_seed_input.text
	))


## Called on the main thread when user presses the "Cancel" button.
func _on_start_game_cancelled() -> void:
	_mutex.lock()
	_is_loading = false
	_mutex.unlock()
	_loading_screen.visible = false
