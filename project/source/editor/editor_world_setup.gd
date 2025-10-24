class_name EditorWorldSetup
extends Node

## The world will be added as a child of this node.
@export var _container: Node
@export var _camera: CustomCamera2D
## The scene's root node must be a WorldVisuals2D.
@export var _world_scene: PackedScene

var editor_settings: AppEditorSettings:
	set(value):
		if editor_settings != null:
			editor_settings.show_decorations.value_changed.disconnect(
					_update_decoration_visibility
			)
		editor_settings = value
		if editor_settings != null:
			editor_settings.show_decorations.value_changed.connect(
					_update_decoration_visibility
			)

var _current_world: WorldVisuals2D:
	set(value):
		_current_world = value
		_province_select_conditions.world_visuals = _current_world

@onready var _province_select_conditions := (
		%ProvinceSelectConditions as ProvinceSelectConditions
)

@onready var _world_overlay := %WorldOverlay as Node


## Discards the current [WorldVisuals2D] instance, if applicable.
func clear() -> void:
	if _current_world != null:
		_current_world.overlay_created.disconnect(_world_overlay.add_child)
		NodeUtils.delete_node(_current_world)
		_current_world = null


## Creates a new [WorldVisuals2D] instance.
## You might want to call "clear()" before calling this.
func load_world(project: GameProject) -> void:
	var new_world := _world_scene.instantiate() as WorldVisuals2D
	new_world.project = project
	new_world.world = project.game.world
	new_world.overlay_created.connect(_world_overlay.add_child)
	_camera.world_limits = project.settings.world_limits
	_camera.move_to_world_center()
	_container.add_child(new_world)
	_current_world = new_world
	_update_decoration_visibility()


## Returns null if the world is not loaded.
func world() -> WorldVisuals2D:
	return _current_world


func _update_decoration_visibility(_item: ItemBool = null) -> void:
	if _current_world == null:
		return
	_current_world.set_decoration_visiblity(
			editor_settings.show_decorations.value
	)
