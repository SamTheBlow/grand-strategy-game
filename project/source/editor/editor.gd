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

## An array of file paths
var _recently_opened_projects: Array[String] = []

@onready var _world_setup := %WorldSetup as EditorWorldSetup
@onready var _world_limits_rect := %WorldLimitsRect2D as WorldLimitsRect2D
@onready var _editor_tab := %Editor as PopupMenu
@onready var _project_tab := %Project as PopupMenu
@onready var _editing_interface := %EditingInterface as EditingInterface
@onready var _popup_container := %PopupContainer as Control
@onready var _save_dialog := %SaveDialog as FileDialog


func _init() -> void:
	_open_new_project()


func _ready() -> void:
	_setup_menu_shortcuts()
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
	_world_setup.world().province_selection.selected_province_changed.connect(
			_on_selected_province_changed
	)
	_world_limits_rect.world_limits = _current_project.game.world.limits()
	_editing_interface.undo_redo = _undo_redo

	_update_window_title()
	_update_menu_visibility()


func _update_window_title() -> void:
	var dirty_string: String = ""
	if _undo_redo.get_version() != _undo_redo_saved_version:
		dirty_string = "*"

	get_window().title = (
			dirty_string
			+ _current_project.metadata.project_name_or_default() + " - "
			+ ProjectSettings.get_setting("application/config/name", "")
	)


## Updates the visibility for all the menu options
func _update_menu_visibility() -> void:
	# "Open Recent"
	_project_tab.set_item_disabled(2, _recently_opened_projects.is_empty())

	_update_menu_visibility_after_save()


## Only updates the visibility of menu options that involve saving
func _update_menu_visibility_after_save() -> void:
	# "Show in File Manager"
	_project_tab.set_item_disabled(
			7, not _current_project.has_valid_file_path()
	)


func _update_undo_redo() -> void:
	_undo_redo_saved_version = _undo_redo.get_version()
	_update_window_title()


func _setup_menu_shortcuts() -> void:
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
	_current_project = GameProject.new()


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
		_update_undo_redo()
		_update_menu_visibility_after_save()
	else:
		_save_dialog.show()


func _play() -> void:
	# TODO implement
	pass


func _open_interface(type: EditingInterface.InterfaceType) -> void:
	if editor_settings == null:
		return

	# Deselect province
	if _world_setup.world() != null:
		_world_setup.world().province_selection.deselect()

	_editing_interface.open_new_interface(
			type, _current_project, editor_settings
	)


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
		0:
			# "Project Info"
			_open_interface(EditingInterface.InterfaceType.PROJECT_INFO)
		2:
			# "World Limits"
			_open_interface(EditingInterface.InterfaceType.WORLD_LIMITS)
		3:
			# "Background Color"
			_open_interface(EditingInterface.InterfaceType.BACKGROUND_COLOR)
		4:
			# "Decorations"
			_open_interface(EditingInterface.InterfaceType.DECORATION_LIST)
		6:
			# "Provinces"
			_open_interface(EditingInterface.InterfaceType.PROVINCE_LIST)
		7:
			# "Countries"
			_open_interface(EditingInterface.InterfaceType.COUNTRY_LIST)
		1, 5:
			# Separators & sub menus
			pass
		_:
			push_error("Unrecognized menu id.")


func _on_project_loaded(project: GameProject) -> void:
	_current_project = project


func _on_save_dialog_file_selected(path: String) -> void:
	# Add the file extension if the user didn't type it in
	if not path.to_lower().ends_with(".json"):
		path = path + ".json"

	_current_project.save_as(path)
	_update_undo_redo()
	_update_menu_visibility_after_save()


func _on_selected_province_changed(province: Province) -> void:
	if province == null:
		_editing_interface.close_interface()
		return
	_editing_interface.open_province_edit_interface(
			province.id, _current_project, editor_settings
	)


func _on_province_interface_opened(province: Province) -> void:
	# Select province
	if _world_setup.world() != null:
		_world_setup.world().province_selection.select(province.id)

	# Show adjacencies on world map
	_world_setup.world().map_mode_setup.set_map_mode(
			MapModeSetup.MapMode.EDITOR_ADJACENCY
	)


func _on_province_interface_closed() -> void:
	if _world_setup.world() == null:
		return

	# Deselect province
	_world_setup.world().province_selection.deselect()

	# Revert the map mode to normal
	_world_setup.world().map_mode_setup.set_map_mode(
			MapModeSetup.MapMode.POLITICAL
	)


func _on_province_change_owner_pressed(province: Province) -> void:
	# Open popup that lets you choose a country
	var popup := _popup_scene.instantiate() as GamePopup
	var country_select_popup := (
			preload("uid://gfcp3xbnck52").instantiate() as CountrySelectPopup
	)
	country_select_popup.country_selected.connect(
		func(country: Country) -> void:
			province.owner_country = country
	)
	country_select_popup.setup(_current_project.game.countries)
	popup.contents_node = country_select_popup
	_popup_container.add_child(popup)


func _on_country_interface_opened(country: Country) -> void:
	# Change map mode
	_world_setup.world().map_mode_setup.set_map_mode_editor_country(country)


func _on_country_interface_closed() -> void:
	if _world_setup.world() == null:
		return

	# Revert the map mode to normal
	_world_setup.world().map_mode_setup.set_map_mode(
			MapModeSetup.MapMode.POLITICAL
	)
