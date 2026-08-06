class_name BackgroundColor
extends Node
## Updates the clear color to match the background color of given [GameWorld].
## When this node is removed from the scene tree,
## reverts the clear color to the default value.

var _world: GameWorld:
	set(value):
		if _world != null:
			_world.background_color_changed.disconnect(_update_clear_color)

		_world = value

		_update_clear_color(_world.background_color)
		_world.background_color_changed.connect(_update_clear_color)


func _exit_tree() -> void:
	_update_clear_color(GameWorld.default_clear_color())


func _update_clear_color(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)


func _on_world_loaded(world_visuals: WorldVisuals2D) -> void:
	_world = world_visuals.world
