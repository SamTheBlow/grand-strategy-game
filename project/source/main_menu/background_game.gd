extends SubViewportContainer
## Creates a [GameNode] that plays a game with no UI and no human players.
## Starts a new game when the game ends.

## The scene's root node must be a [GameNode].
@export var _game_scene: PackedScene

## The file path of the game to play.
@export var _project_file_path: String = "res://assets/save_files/test1.json"

var _load_thread := Thread.new()
var _background_game_node: GameNode

@onready var _background_viewport := %BackgroundViewport as SubViewport


func _ready() -> void:
	_load_new_game()


func _exit_tree() -> void:
	if _load_thread.is_started():
		_load_thread.wait_to_finish()


func _load_new_game() -> void:
	if _load_thread.is_started():
		_load_thread.wait_to_finish()

	_load_thread.start(_setup_game.bind(_project_file_path))


## Called in a separate thread.
func _setup_game(project_file_path: String) -> void:
	var metadata: GameMetadata = GameMetadata.from_file_path(project_file_path)
	if metadata == null:
		_on_game_load_error.call_deferred("Invalid project file path")
		return

	var generated_game: GameLoadGenerated.ParseResult = (
			GameLoadGenerated.result(metadata, GameRules.new())
	)
	if generated_game.error:
		_on_game_load_error.call_deferred(generated_game.error_message)
	else:
		_on_game_load_ready.call_deferred(generated_game.result_project)


## Called on the main thread when the other thread is done.
func _on_game_load_ready(project: GameProject) -> void:
	if _background_game_node != null:
		_background_viewport.remove_child(_background_game_node)
		_background_game_node.queue_free()

	project.game.game_over.connect(_on_game_over)
	_background_game_node = _game_scene.instantiate() as GameNode
	_background_game_node.project = project
	_background_game_node.is_ui_visible = false
	_background_viewport.add_child(_background_game_node)


## Called on the main thread when the other thread encounters an error.
func _on_game_load_error(error_message: String) -> void:
	push_warning("Failed to load background game: ", error_message)


## Start a new game whenever the current game ends.
func _on_game_over(_winner: Country) -> void:
	_load_new_game()
