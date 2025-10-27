@tool
class_name WorldLimitsRect2D
extends Rect2D
## [Rect2D] that automatically updates according to given
## [AppEditorSettings] and [WorldLimits].

## May be null.
var editor_settings: AppEditorSettings:
	set(value):
		_disconnect_editor_settings()
		editor_settings = value
		_connect_editor_settings()
		if editor_settings != null:
			_update_world_limits_visible(editor_settings.show_world_limits)
			_update_world_limits_color(editor_settings.world_limits_color)

## May be null.
var world_limits: WorldLimits:
	set(value):
		if world_limits != null:
			world_limits.current_limits_changed.disconnect(_update_rectangle)
		world_limits = value
		_update_rectangle()
		if world_limits != null:
			world_limits.current_limits_changed.connect(_update_rectangle)


func _update_world_limits_visible(property: ItemBool) -> void:
	visible = property.value


func _update_world_limits_color(property: ItemColor) -> void:
	modulate = property.value
	queue_redraw()


func _update_rectangle(_world_limits: WorldLimits = null) -> void:
	if world_limits == null:
		rectangle = Rect2(
				WorldLimits.DEFAULT_LEFT,
				WorldLimits.DEFAULT_TOP,
				WorldLimits.DEFAULT_RIGHT - WorldLimits.DEFAULT_LEFT,
				WorldLimits.DEFAULT_BOTTOM - WorldLimits.DEFAULT_TOP
		)
	else:
		rectangle = world_limits.as_rect2i()
	queue_redraw()


func _disconnect_editor_settings() -> void:
	if editor_settings == null:
		return

	editor_settings.show_world_limits.value_changed.disconnect(
			_update_world_limits_visible
	)
	editor_settings.world_limits_color.value_changed.disconnect(
			_update_world_limits_color
	)


func _connect_editor_settings() -> void:
	if editor_settings == null:
		return

	editor_settings.show_world_limits.value_changed.connect(
			_update_world_limits_visible
	)
	editor_settings.world_limits_color.value_changed.connect(
			_update_world_limits_color
	)
