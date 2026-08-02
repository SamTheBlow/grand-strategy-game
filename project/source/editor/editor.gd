class_name Editor
extends Node
## The game editor where users make their own games.

signal exited()

var editor_settings := AppEditorSettings.new()

var _current_project := GameProject.new()

var _undo_redo: UndoRedo

## Keeps track of at what point the project was last saved.
var _undo_redo_saved_version: int = 1

@onready var _menus := %Menus as EditorMenus
@onready var _world_bridge := %WorldBridge as EditorWorldBridge
@onready var _project_io := %ProjectIO as EditorProjectIO
@onready var _world_setup := %WorldSetup as EditorWorldSetup
@onready var _world_limits_rect := %WorldLimitsRect2D as WorldLimitsRect2D
@onready var _editing_interface := %EditingInterface as EditingInterface


func _ready() -> void:
	_menus.quit_requested.connect(exited.emit)

	_world_bridge.editor_settings = editor_settings
	_world_setup.editor_settings = editor_settings
	_world_limits_rect.editor_settings = editor_settings
	_setup_project()


func _exit_tree() -> void:
	# Reset the window title
	get_window().title = (
			ProjectSettings.get_setting("application/config/name", "")
	)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_undo"):
		_undo_redo.undo()
	elif Input.is_action_just_pressed(&"ui_redo"):
		_undo_redo.redo()


func _setup_project() -> void:
	# We close any currently open interface
	# because it may be using data from the previous project.
	_editing_interface.close_interface()

	# Setup a new UndoRedo instance
	if _undo_redo != null:
		_undo_redo.version_changed.disconnect(_update_window_title)
	_undo_redo = UndoRedo.new()
	_undo_redo.version_changed.connect(_update_window_title)

	# Clear existing data
	_world_setup.clear()
	_world_limits_rect.world_limits = null

	# Setup the world visuals
	_world_setup.load_world(_current_project)

	# Give new data to nodes
	_world_limits_rect.world_limits = _current_project.game.world.limits()
	_editing_interface.undo_redo = _undo_redo

	# Give the [UndoRedo] system to the editor map mode
	# TODO this is ugly!!!
	var map_mode_editor_adjacency := (
			_world_setup.world().get_node_or_null("%EditorAdjacency")
			as MapModeEditorAdjacency
	)
	if map_mode_editor_adjacency != null:
		map_mode_editor_adjacency.undo_redo = _undo_redo
	else:
		push_warning("Could not get the editor adjacancy map mode")

	_menus.current_project = _current_project
	_project_io.current_project = _current_project

	_update_window_title()


func _update_window_title() -> void:
	var dirty_string: String = ""
	if _undo_redo.get_version() != _undo_redo_saved_version:
		dirty_string = "*"

	get_window().title = (
			dirty_string
			+ _current_project.metadata.project_name_or_default() + " - "
			+ ProjectSettings.get_setting("application/config/name", "")
	)


func _play() -> void:
	# TODO implement
	pass


func _open_interface(type: EditingInterface.InterfaceType) -> void:
	_editing_interface.open_new_interface(
			type, _current_project, editor_settings
	)


## Called when a new project is loaded.
## Rebuilds the whole editor state.
func _on_project_loaded(project: GameProject) -> void:
	_current_project = project
	_setup_project()


## Called after the current project has been saved to disk.
func _on_project_saved() -> void:
	_undo_redo_saved_version = _undo_redo.get_version()
	_update_window_title()

	_menus.update_menu_visibility_after_save()
