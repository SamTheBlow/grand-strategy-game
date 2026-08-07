class_name Editor
extends Node
## The game editor where users make their own games.

signal exited()

var editor_settings := AppEditorSettings.new()

@onready var _menus := %Menus as EditorMenus
@onready var _project_io := %ProjectIO as EditorProjectIO
@onready var _undo_redo_node := %UndoRedo as UndoRedoNode
@onready var _project_node := %ProjectNode as ProjectNode

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

	_setup_project(GameProject.new())


func _setup_project(project: GameProject) -> void:
	_world_visuals.project = project

	_project_node.set_project(project)
	_project_io.current_project = project
	_editing_interface.project = project


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
	_undo_redo_node.reset()

	_setup_project(project)
