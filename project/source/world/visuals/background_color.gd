class_name BackgroundColor
extends Node
## Sets the clear color to match the background color of given [GameWorld].
## When this node leaves the scene tree,
## reverts the clear color to the default value.

var _world: GameWorld


func _enter_tree() -> void:
	if _world != null:
		_set_clear_color(_world.background_color)


func _exit_tree() -> void:
	if _world != null:
		_set_clear_color(GameWorld.default_clear_color())


func _set_clear_color(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)


func _on_world_loaded(world_visuals: WorldVisuals2D) -> void:
	if _world != null:
		_world.background_color_changed.disconnect(_set_clear_color)

	_world = world_visuals.world
	_set_clear_color(_world.background_color)

	_world.background_color_changed.connect(_set_clear_color)
