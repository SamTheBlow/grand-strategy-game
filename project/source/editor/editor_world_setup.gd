class_name EditorWorldSetup
extends Node
## Handles setting up a new [WorldVisuals2D].

signal loaded(project: GameProject, world_visuals: WorldVisuals2D)

const _WORLD_SCENE := preload("uid://dpgoa2yg5bjcp") as PackedScene
const _CAMERA_SCENE := preload("uid://44rygdcojakm") as PackedScene

## The world will be added as a child of this node.
@export var _world_container: Node
## The camera will be added as a child of this node.
@export var _camera_container: Node

var editor_settings: AppEditorSettings:
	set(value):
		if editor_settings != null:
			editor_settings.show_decorations.value_changed.disconnect(
					_refresh_decoration_visibility
			)

		editor_settings = value

		editor_settings.show_decorations.value_changed.connect(
				_refresh_decoration_visibility.unbind(1)
		)

var _world: WorldVisuals2D
var _camera: CustomCamera2D

@onready var _world_overlay := %WorldOverlay as Node


## Sets up a new [WorldVisuals2D] instance.
## Clears existing data beforehand.
func setup_world(project: GameProject) -> void:
	if _world != null:
		_world.overlay_created.disconnect(_world_overlay.add_child)
		NodeUtils.delete_node(_world)

	_world = _WORLD_SCENE.instantiate() as WorldVisuals2D
	_world.project = project
	_world.overlay_created.connect(_world_overlay.add_child)
	_world_container.add_child(_world)

	if _camera != null:
		NodeUtils.delete_node(_camera)

	_camera = _CAMERA_SCENE.instantiate() as CustomCamera2D
	_camera_container.add_child(_camera)
	_camera.world_limits = project.game.world.limits()
	_camera.move_to_world_center()

	_refresh_decoration_visibility()

	loaded.emit(project, _world)


## Returns null if the world is not loaded.
func world() -> WorldVisuals2D:
	return _world


func _refresh_decoration_visibility() -> void:
	_world.set_decoration_visiblity(editor_settings.show_decorations.value)
