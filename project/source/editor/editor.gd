class_name Editor
extends Node
## The game editor where users make their own games.

signal exited()

const INPUT_ACTION_QUIT_EDITOR: String = "quit_editor"
const INPUT_ACTION_NEW_PROJECT: String = "new_project"
const INPUT_ACTION_OPEN_PROJECT: String = "open_project"
const INPUT_ACTION_SAVE: String = "save"
const INPUT_ACTION_SAVE_AS: String = "save_as"
const INPUT_ACTION_PLAY_PROJECT: String = "play_project"

## The scene's root node must be a [GamePopup].
@export var _popup_scene: PackedScene
## The scene's root node must be a [ProjectLoadPopup].
@export var _project_load_popup_scene: PackedScene

var _current_project: EditorProject:
	set(value):
		_current_project = value
		_setup_project()
		_update_window_title()
		_update_menu_visibility()

## An array of file paths
var _recently_opened_projects: Array[String] = []

@onready var _world_setup := %WorldSetup as EditorWorldSetup
@onready var _editor_tab := %Editor as PopupMenu
@onready var _project_tab := %Project as PopupMenu
@onready var _editing_interface := %EditingInterface as EditingInterface
@onready var _popup_container := %PopupContainer as Control
@onready var _save_dialog := %SaveDialog as FileDialog


func _ready() -> void:
	_set_menu_shortcuts()
	_open_new_project()


func _exit_tree() -> void:
	# Reset the window title
	_current_project = null


func _setup_project() -> void:
	if not is_node_ready():
		return

	_world_setup.clear()

	if _current_project == null:
		return

	_world_setup.load_world(_current_project.game)


func _update_window_title() -> void:
	get_window().title = (
			_window_title_prefix()
			+ ProjectSettings.get_setting("application/config/name", "")
	)


## If there is no current project, returns an empty string.
func _window_title_prefix() -> String:
	if _current_project == null:
		return ""
	return _current_project.name + " - "


## Updates the visibility for all the menu options
func _update_menu_visibility() -> void:
	if not is_node_ready():
		return

	# "Open Recent"
	_project_tab.set_item_disabled(2, _recently_opened_projects.is_empty())

	# "Save"
	_project_tab.set_item_disabled(4, _current_project == null)
	# "Save As..."
	_project_tab.set_item_disabled(5, _current_project == null)

	# "Play"
	_project_tab.set_item_disabled(9, _current_project == null)

	_update_menu_visibility_after_save()


## Only updates the visibility of menu options that involve saving
func _update_menu_visibility_after_save() -> void:
	# "Show in File Manager"
	_project_tab.set_item_disabled(
			7,
			_current_project == null
			or not _current_project.has_valid_file_path()
	)


func _set_menu_shortcuts() -> void:
	if not is_node_ready():
		return

	var shortcut_quit := Shortcut.new()
	shortcut_quit.events = InputMap.action_get_events(INPUT_ACTION_QUIT_EDITOR)
	_editor_tab.set_item_shortcut(2, shortcut_quit)

	var shortcut_new := Shortcut.new()
	shortcut_new.events = InputMap.action_get_events(INPUT_ACTION_NEW_PROJECT)
	_project_tab.set_item_shortcut(0, shortcut_new)

	var shortcut_open := Shortcut.new()
	shortcut_open.events = InputMap.action_get_events(INPUT_ACTION_OPEN_PROJECT)
	_project_tab.set_item_shortcut(1, shortcut_open)

	var shortcut_save := Shortcut.new()
	shortcut_save.events = InputMap.action_get_events(INPUT_ACTION_SAVE)
	_project_tab.set_item_shortcut(4, shortcut_save)

	var shortcut_save_as := Shortcut.new()
	shortcut_save_as.events = InputMap.action_get_events(INPUT_ACTION_SAVE_AS)
	_project_tab.set_item_shortcut(5, shortcut_save_as)

	var shortcut_play := Shortcut.new()
	shortcut_play.events = InputMap.action_get_events(INPUT_ACTION_PLAY_PROJECT)
	_project_tab.set_item_shortcut(9, shortcut_play)


func _open_editor_settings() -> void:
	# TODO implement
	pass


func _open_new_project() -> void:
	_current_project = EditorProject.new()


func _open_project() -> void:
	var popup := _popup_scene.instantiate() as GamePopup
	var project_load_popup := (
			_project_load_popup_scene.instantiate() as ProjectLoadPopup
	)
	project_load_popup.project_loaded.connect(_on_project_loaded)
	popup.contents_node = project_load_popup
	_popup_container.add_child(popup)


## If the project doesn't have a file path assigned, opens the file dialog.
func _save_project() -> void:
	if _current_project.has_valid_file_path():
		_current_project.save()
		_update_menu_visibility_after_save()
	else:
		_save_dialog.show()


func _play() -> void:
	# TODO implement
	pass


func _open_interface(type: EditingInterface.InterfaceType) -> void:
	_editing_interface.open_interface(type)


## Called when the user clicks on one of the options
## in the menu bar's "Editor" tab.
func _on_editor_tab_id_pressed(id: int) -> void:
	match id:
		0:
			# "Editor Settings..."
			_open_editor_settings()
		2:
			# "Quit"
			exited.emit()
		1:
			# Separators & sub menus
			pass
		_:
			push_error("Unrecognized menu id.")


## Called when the user clicks on one of the options
## in the menu bar's "Project" tab.
func _on_project_tab_id_pressed(id: int) -> void:
	match id:
		0:
			# "New Project"
			_open_new_project()
		1:
			# "Open..."
			_open_project()
		4:
			# "Save"
			_save_project()
		5:
			# "Save As..."
			_save_dialog.show()
		7:
			# "Show in File Manager"
			_current_project.show_in_file_manager()
		9:
			# "Play"
			_play()
		2, 3, 6, 8:
			# Separators & sub menus
			pass
		_:
			push_error("Unrecognized menu id.")


func _on_edit_tab_id_pressed(id: int) -> void:
	match id:
		1:
			# "World Limits"
			_open_interface(EditingInterface.InterfaceType.WORLD_LIMITS)
		2:
			# "Background Color"
			_open_interface(EditingInterface.InterfaceType.BACKGROUND_COLOR)
		3:
			# "Decoration"
			_open_interface(EditingInterface.InterfaceType.DECORATION)
		0:
			# Separators & sub menus
			pass
		_:
			push_error("Unrecognized menu id.")


func _on_project_loaded(project: EditorProject) -> void:
	_current_project = project


func _on_save_dialog_file_selected(path: String) -> void:
	if _current_project != null:
		_current_project.save_as(path)
		_update_menu_visibility_after_save()
