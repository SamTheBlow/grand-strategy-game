class_name BackgroundColor
extends Node
## Updates the clear color to match the value of given [ItemColor].
## When this node is removed from the scene tree,
## reverts the clear color to what it was before this node was introduced.

var background_color: ItemColor:
	set(value):
		if background_color != null:
			background_color.value_changed.disconnect(
					_on_background_color_changed
			)

		background_color = value

		if background_color != null:
			background_color.value_changed.connect(
					_on_background_color_changed
			)
			_update_clear_color(background_color.value)
		else:
			_update_clear_color(_original_clear_color)

var _original_clear_color: Color = ProjectSettings.get_setting(
		"rendering/environment/defaults/default_clear_color",
		Color(0.3, 0.3, 0.3)
)


func _exit_tree() -> void:
	_update_clear_color(_original_clear_color)


func _update_clear_color(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)


func _on_background_color_changed(item: ItemColor) -> void:
	_update_clear_color(item.value)
