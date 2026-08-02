class_name Editor
extends Node
## The game editor where users make their own games.

signal exited()

const _GAME_POPUP_SCENE: PackedScene = preload("uid://by865efl4iwy")
const _PROJECT_LOAD_POPUP_SCENE: PackedScene = preload("uid://df5yjnsebj5np")

var editor_settings := AppEditorSettings.new()

var _current_project: GameProject:
	set(value):
		_current_project = value
		_undo_redo = UndoRedo.new()
		if is_node_ready():
			_setup_project()

var _undo_redo: UndoRedo:
	set(value):
		if _undo_redo != null:
			_undo_redo.version_changed.disconnect(_update_window_title)
		_undo_redo = value
		_undo_redo.version_changed.connect(_update_window_title)

## Keeps track of at what point the project was last saved.
var _undo_redo_saved_version: int = 1

@onready var _menus := %Menus as EditorMenus
@onready var _world_bridge := %WorldBridge as EditorWorldBridge
@onready var _world_setup := %WorldSetup as EditorWorldSetup
@onready var _world_limits_rect := %WorldLimitsRect2D as WorldLimitsRect2D
@onready var _editing_interface := %EditingInterface as EditingInterface
@onready var _popup_container := %PopupContainer as Control
@onready var _save_dialog := %SaveDialog as FileDialog


func _init() -> void:
	_open_new_project()


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
	_world_setup.clear()
	_world_limits_rect.world_limits = null
	# We close the interface
	# because it may be using data from the previous project.
	_editing_interface.close_interface()

	_world_setup.load_world(_current_project)
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


func _update_undo_redo() -> void:
	_undo_redo_saved_version = _undo_redo.get_version()
	_update_window_title()


func _open_new_project() -> void:
	_current_project = GameProject.new()


func _open_project() -> void:
	var popup := _GAME_POPUP_SCENE.instantiate() as GamePopup
	var project_load_popup := (
			_PROJECT_LOAD_POPUP_SCENE.instantiate() as ProjectLoadPopup
	)
	project_load_popup.project_loaded.connect(_on_project_loaded)
	popup.contents_node = project_load_popup
	_popup_container.add_child(popup)


## If the project doesn't have a file path assigned, opens the file dialog.
func _save_project() -> void:
	if _current_project.has_valid_file_path():
		_current_project.save()
		_update_undo_redo()
		_menus.update_menu_visibility_after_save()
	else:
		_save_dialog.show()


func _play() -> void:
	# TODO implement
	pass


func _open_interface(type: EditingInterface.InterfaceType) -> void:
	_editing_interface.open_new_interface(
			type, _current_project, editor_settings
	)


func _on_project_loaded(project: GameProject) -> void:
	_current_project = project


func _on_save_dialog_file_selected(path: String) -> void:
	# Add the file extension if the user didn't type it in
	if not path.to_lower().ends_with(".json"):
		path = path + ".json"

	_current_project.save_as(path)
	_update_undo_redo()
	_menus.update_menu_visibility_after_save()
