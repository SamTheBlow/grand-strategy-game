class_name Editor
extends Node
## The game editor where users make their own games.

signal exited()

var editor_settings := AppEditorSettings.new()

var _current_project := GameProject.new()

@onready var _menus := %Menus as EditorMenus
@onready var _project_io := %ProjectIO as EditorProjectIO
@onready var _history := %History as EditorHistory

@onready var _world_visuals := %WorldVisuals2D as WorldVisuals2D
@onready var _editing_interface := %EditingInterface as EditingInterface


func _ready() -> void:
	_menus.quit_requested.connect(exited.emit)

	var world_limits_rect := %WorldLimitsRect2D as WorldLimitsRect2D
	world_limits_rect.editor_settings = editor_settings
	_editing_interface.editor_settings = editor_settings

	# Show/hide decorations whenever the setting changes.
	_refresh_decoration_visibility()
	editor_settings.show_decorations.value_changed.connect(
			_refresh_decoration_visibility.unbind(1)
	)

	_setup_project()


func _exit_tree() -> void:
	# Reset the window title
	get_window().title = (
			ProjectSettings.get_setting("application/config/name", "")
	)


func _setup_project() -> void:
	_history.reset()
	_world_visuals.project = _current_project
	_menus.current_project = _current_project
	_project_io.current_project = _current_project
	_editing_interface.project = _current_project
	_update_window_title()


func _update_window_title() -> void:
	var dirty_indicator: String = "*" if _history.is_dirty() else ""
	get_window().title = (
			dirty_indicator
			+ _current_project.metadata.project_name_or_default() + " - "
			+ ProjectSettings.get_setting("application/config/name", "")
	)


func _refresh_decoration_visibility() -> void:
	_world_visuals.set_decoration_visiblity(
			editor_settings.show_decorations.value
	)


func _play() -> void:
	# TODO implement
	pass


## Called when a new project is loaded.
## Rebuilds the whole editor state.
func _on_project_loaded(project: GameProject) -> void:
	_editing_interface.close_interface()
	_current_project = project
	_setup_project()
