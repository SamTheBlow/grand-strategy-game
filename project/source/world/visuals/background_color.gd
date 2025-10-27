class_name BackgroundColor
extends Node
## Updates the clear color to match the background color of given [GameWorld].
## When this node is removed from the scene tree,
## reverts the clear color to the default value.

## May be null.
var world: GameWorld:
	set(value):
		if world != null:
			world.background_color_changed.disconnect(_update_clear_color)

		world = value

		if world != null:
			_update_clear_color(world.background_color)
			world.background_color_changed.connect(_update_clear_color)
		else:
			_update_clear_color(default_clear_color())


func _exit_tree() -> void:
	_update_clear_color(default_clear_color())


static func default_clear_color() -> Color:
	return ProjectSettings.get_setting(
			"rendering/environment/defaults/default_clear_color",
			Color(0.3, 0.3, 0.3)
	)


static func _update_clear_color(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)
