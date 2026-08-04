class_name Editor
extends Node
## The game editor where users make their own games.

signal exited()

var editor_settings := AppEditorSettings.new()

var _current_project := GameProject.new()

@onready var _menus := %Menus as EditorMenus
@onready var _world_bridge := %WorldBridge as EditorWorldBridge
@onready var _project_io := %ProjectIO as EditorProjectIO
@onready var _history := %History as EditorHistory

@onready var _world_setup := %WorldSetup as EditorWorldSetup
@onready var _world_limits_rect := %WorldLimitsRect2D as WorldLimitsRect2D
@onready var _editing_interface := %EditingInterface as EditingInterface
@onready var _decoration_input := %DecorationInput as DecorationVisualsInput


func _ready() -> void:
	_menus.quit_requested.connect(exited.emit)

	_world_bridge.editor_settings = editor_settings
	_world_setup.editor_settings = editor_settings
	_world_limits_rect.editor_settings = editor_settings
	_decoration_input.editor_settings = editor_settings

	_setup_project()


func _exit_tree() -> void:
	# Reset the window title
	get_window().title = (
			ProjectSettings.get_setting("application/config/name", "")
	)


func _setup_project() -> void:
	_history.reset()

	_world_setup.setup_world(_current_project)
	_world_limits_rect.world_limits = _current_project.game.world.limits()

	_menus.current_project = _current_project
	_project_io.current_project = _current_project

	_update_window_title()


func _update_window_title() -> void:
	var dirty_indicator: String = "*" if _history.is_dirty() else ""
	get_window().title = (
			dirty_indicator
			+ _current_project.metadata.project_name_or_default() + " - "
			+ ProjectSettings.get_setting("application/config/name", "")
	)


func _play() -> void:
	# TODO implement
	pass


func _open_interface(type: InterfaceNavigator.InterfaceType) -> void:
	_editing_interface.open_new_interface(
			type, _current_project, editor_settings
	)


## Called when a new project is loaded.
## Rebuilds the whole editor state.
func _on_project_loaded(project: GameProject) -> void:
	# We close any currently open interface
	# because it may be using data from the previous project.
	_editing_interface.close_interface()

	_current_project = project
	_setup_project()
