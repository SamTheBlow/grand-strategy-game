class_name Editor
extends Node
## The game editor where users make their own games.

signal exited()

@export var _editor_settings: AppEditorSettings

@onready var _undo_redo_node := %UndoRedo as UndoRedoNode
@onready var _project_node := %ProjectNode as ProjectNode

@onready var _world_visuals := %WorldVisuals2D as WorldVisuals2D
@onready var _editing_interface := %EditingInterface as EditingInterface


func _ready() -> void:
	# Show/hide decorations whenever the setting changes.
	_refresh_decoration_visibility()
	_editor_settings.show_decorations.value_changed.connect(
			_refresh_decoration_visibility.unbind(1)
	)

	_setup_project(GameProject.new())


func exit() -> void:
	exited.emit()


func _setup_project(project: GameProject) -> void:
	_project_node.set_project(project)
	_world_visuals.set_project(project)
	_editing_interface.project = project


func _refresh_decoration_visibility() -> void:
	_world_visuals.set_decoration_visiblity(
			_editor_settings.show_decorations.value
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
