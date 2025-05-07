@tool
class_name WorldLimitsRect2D
extends Rect2D
## [Rect2D] that automatically updates according to given
## [AppEditorSettings] and [GameSettings].

var editor_settings: AppEditorSettings:
	set(value):
		_disconnect_editor_settings()
		editor_settings = value
		_connect_editor_settings()
		_update_editor_settings()

var game_settings: GameSettings:
	set(value):
		_disconnect_game_settings()
		game_settings = value

		if game_settings != null:
			rectangle = game_settings.world_limits.as_rect2i()
		else:
			rectangle = WorldLimits.new().as_rect2i()
		queue_redraw()

		_connect_game_settings()
		_update_game_settings()


func _update_editor_settings() -> void:
	if editor_settings == null:
		return

	_update_world_limits_visible(editor_settings.show_world_limits)
	_update_world_limits_color(editor_settings.world_limits_color)


func _update_world_limits_visible(property: ItemBool) -> void:
	visible = property.value


func _update_world_limits_color(property: ItemColor) -> void:
	modulate = property.value
	queue_redraw()


func _update_game_settings() -> void:
	if game_settings == null:
		return

	_update_custom_world_limits()


func _update_custom_world_limits(_world_limits: WorldLimits = null) -> void:
	rectangle = game_settings.world_limits.as_rect2i()
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


func _disconnect_game_settings() -> void:
	if game_settings == null:
		return

	game_settings.world_limits.changed.disconnect(_update_custom_world_limits)


func _connect_game_settings() -> void:
	if game_settings == null:
		return

	game_settings.world_limits.changed.connect(_update_custom_world_limits)
