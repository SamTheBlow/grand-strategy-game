class_name EditorMenus
extends Node
## The menu bar of the editor.
## Translates raw menu button presses into signals.

signal quit_requested()
signal new_project_requested()
signal open_project_requested()
signal save_requested()
signal save_as_requested()
signal play_requested()
signal interface_requested(type: EditingInterface.InterfaceType)

const INPUT_ACTION_QUIT_EDITOR: StringName = &"quit_editor"
const INPUT_ACTION_NEW_PROJECT: StringName = &"new_project"
const INPUT_ACTION_OPEN_PROJECT: StringName = &"open_project"
const INPUT_ACTION_SAVE: StringName = &"save"
const INPUT_ACTION_SAVE_AS: StringName = &"save_as"
const INPUT_ACTION_PLAY_PROJECT: StringName = &"play_project"

const EDITOR_TAB_SEPARATOR_IDS: Array[int] = []
const EDITOR_TAB_QUIT_ID: int = 0

const PROJECT_TAB_SEPARATOR_IDS: Array[int] = [2, 5, 7]
const PROJECT_TAB_NEW_PROJECT_ID: int = 0
const PROJECT_TAB_OPEN_ID: int = 1
const PROJECT_TAB_SAVE_ID: int = 3
const PROJECT_TAB_SAVE_AS_ID: int = 4
const PROJECT_TAB_SHOW_IN_FILE_MANAGER_ID: int = 6
const PROJECT_TAB_PLAY_ID: int = 8

const EDIT_TAB_SEPARATOR_IDS: Array[int] = [2, 6]
const EDIT_TAB_PROJECT_INFO_ID: int = 0
const EDIT_TAB_RNG_ID: int = 1
const EDIT_TAB_COUNTRIES_ID: int = 3
const EDIT_TAB_PLAYERS_ID: int = 4
const EDIT_TAB_TURN_ORDER_ID: int = 5
const EDIT_TAB_WORLD_LIMITS_ID: int = 7
const EDIT_TAB_BACKGROUND_COLOR_ID: int = 8
const EDIT_TAB_DECORATIONS_ID: int = 9
const EDIT_TAB_PROVINCES_ID: int = 10
const EDIT_TAB_ARMIES_ID: int = 11

## The project that is currently being edited.
## Determines which menu options are available.
var current_project: GameProject:
	set(value):
		if current_project == value:
			return
		current_project = value
		if is_node_ready():
			update_menu_visibility()

@onready var _editor_tab := %Editor as PopupMenu
@onready var _project_tab := %Project as PopupMenu


func _ready() -> void:
	_setup_menu_shortcuts()


## Updates the visibility for all the menu options
func update_menu_visibility() -> void:
	update_menu_visibility_after_save()


## Only updates the visibility of menu options that involve saving
func update_menu_visibility_after_save() -> void:
	# "Show in File Manager"
	_project_tab.set_item_disabled(
			PROJECT_TAB_SHOW_IN_FILE_MANAGER_ID,
			not current_project.has_valid_file_path()
	)


func _setup_menu_shortcuts() -> void:
	var shortcut_quit := Shortcut.new()
	shortcut_quit.events = InputMap.action_get_events(INPUT_ACTION_QUIT_EDITOR)
	_editor_tab.set_item_shortcut(EDITOR_TAB_QUIT_ID, shortcut_quit)

	var shortcut_new := Shortcut.new()
	shortcut_new.events = InputMap.action_get_events(INPUT_ACTION_NEW_PROJECT)
	_project_tab.set_item_shortcut(PROJECT_TAB_NEW_PROJECT_ID, shortcut_new)

	var shortcut_open := Shortcut.new()
	shortcut_open.events = InputMap.action_get_events(INPUT_ACTION_OPEN_PROJECT)
	_project_tab.set_item_shortcut(PROJECT_TAB_OPEN_ID, shortcut_open)

	var shortcut_save := Shortcut.new()
	shortcut_save.events = InputMap.action_get_events(INPUT_ACTION_SAVE)
	_project_tab.set_item_shortcut(PROJECT_TAB_SAVE_ID, shortcut_save)

	var shortcut_save_as := Shortcut.new()
	shortcut_save_as.events = InputMap.action_get_events(INPUT_ACTION_SAVE_AS)
	_project_tab.set_item_shortcut(PROJECT_TAB_SAVE_AS_ID, shortcut_save_as)

	var shortcut_play := Shortcut.new()
	shortcut_play.events = InputMap.action_get_events(INPUT_ACTION_PLAY_PROJECT)
	_project_tab.set_item_shortcut(PROJECT_TAB_PLAY_ID, shortcut_play)


## Called when the user clicks on one of the options
## in the menu bar's "Editor" tab.
func _on_editor_tab_id_pressed(id: int) -> void:
	match id:
		EDITOR_TAB_QUIT_ID:
			# "Quit"
			quit_requested.emit()
		EDITOR_TAB_SEPARATOR_IDS:
			pass
		_:
			push_error("Unrecognized menu id.")


## Called when the user clicks on one of the options
## in the menu bar's "Project" tab.
func _on_project_tab_id_pressed(id: int) -> void:
	match id:
		PROJECT_TAB_NEW_PROJECT_ID:
			# "New Project"
			new_project_requested.emit()
		PROJECT_TAB_OPEN_ID:
			# "Open..."
			open_project_requested.emit()
		PROJECT_TAB_SAVE_ID:
			# "Save"
			save_requested.emit()
		PROJECT_TAB_SAVE_AS_ID:
			# "Save As..."
			save_as_requested.emit()
		PROJECT_TAB_SHOW_IN_FILE_MANAGER_ID:
			# "Show in File Manager"
			current_project.show_in_file_manager()
		PROJECT_TAB_PLAY_ID:
			# "Play"
			play_requested.emit()
		PROJECT_TAB_SEPARATOR_IDS:
			# Separators & sub menus
			pass
		_:
			push_error("Unrecognized menu id.")


## Called when the user clicks on one of the options
## in the menu bar's "Edit" tab.
func _on_edit_tab_id_pressed(id: int) -> void:
	var interface_type: EditingInterface.InterfaceType

	match id:
		EDIT_TAB_PROJECT_INFO_ID:
			# "Project Info"
			interface_type = EditingInterface.InterfaceType.PROJECT_INFO
		EDIT_TAB_RNG_ID:
			# "RNG"
			interface_type = EditingInterface.InterfaceType.RNG
		EDIT_TAB_COUNTRIES_ID:
			# "Countries"
			interface_type = EditingInterface.InterfaceType.COUNTRY_LIST
		EDIT_TAB_PLAYERS_ID:
			# "Players"
			interface_type = EditingInterface.InterfaceType.PLAYER_LIST
		EDIT_TAB_TURN_ORDER_ID:
			# "Turn Order"
			interface_type = EditingInterface.InterfaceType.TURN_ORDER
		EDIT_TAB_WORLD_LIMITS_ID:
			# "World Limits"
			interface_type = EditingInterface.InterfaceType.WORLD_LIMITS
		EDIT_TAB_BACKGROUND_COLOR_ID:
			# "Background Color"
			interface_type = EditingInterface.InterfaceType.BACKGROUND_COLOR
		EDIT_TAB_DECORATIONS_ID:
			# "Decorations"
			interface_type = EditingInterface.InterfaceType.DECORATION_LIST
		EDIT_TAB_PROVINCES_ID:
			# "Provinces"
			interface_type = EditingInterface.InterfaceType.PROVINCE_LIST
		EDIT_TAB_ARMIES_ID:
			# "Armies"
			interface_type = EditingInterface.InterfaceType.ARMY_LIST
		EDIT_TAB_SEPARATOR_IDS:
			# Separators & sub menus
			return
		_:
			push_error("Unrecognized menu id.")
			return

	interface_requested.emit(interface_type)
