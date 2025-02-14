class_name EditorWorldSetup
extends Node

## The world will be added as a child of this node.
@export var _container: Node
@export var _camera: CustomCamera2D
## The scene's root node must be a WorldVisuals2D.
@export var _world_scene: PackedScene

var _current_world: Node


## Discards the current [WorldVisuals2D] instance, if applicable.
func clear() -> void:
	if _current_world != null:
		_current_world.get_parent().remove_child(_current_world)
		_current_world.queue_free()


## Creates a new [WorldVisuals2D] instance.
## You might want to call "clear()" before calling this.
func load_world(game: Game) -> void:
	if game.world is not GameWorld2D:
		return

	var new_world := _world_scene.instantiate() as WorldVisuals2D
	new_world.world = game.world as GameWorld2D
	new_world.game = game
	_camera.world_limits = (game.world as GameWorld2D).limits
	_camera.move_to_world_center()
	_container.add_child(new_world)
	_current_world = new_world
