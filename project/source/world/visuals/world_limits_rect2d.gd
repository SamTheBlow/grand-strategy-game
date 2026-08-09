@tool
class_name WorldLimitsRect2D
extends Rect2D
## [Rect2D] that automatically updates according to
## given [AppEditorSettings] and given limits.

@export var _editor_settings: AppEditorSettings


func _ready() -> void:
	rectangle = Rect2(
			WorldLimits.DEFAULT_LEFT,
			WorldLimits.DEFAULT_TOP,
			WorldLimits.DEFAULT_RIGHT - WorldLimits.DEFAULT_LEFT,
			WorldLimits.DEFAULT_BOTTOM - WorldLimits.DEFAULT_TOP
	)

	if Engine.is_editor_hint():
		return

	_update_world_limits_visible(_editor_settings.show_world_limits)
	_editor_settings.show_world_limits.value_changed.connect(
			_update_world_limits_visible
	)
	_update_world_limits_color(_editor_settings.world_limits_color)
	_editor_settings.world_limits_color.value_changed.connect(
			_update_world_limits_color
	)


func set_limits(left: float, top: float, right: float, bottom: float) -> void:
	rectangle = Rect2(left, top, right - left, bottom - top)
	queue_redraw()


func _update_world_limits_visible(property: ItemBool) -> void:
	visible = property.value


func _update_world_limits_color(property: ItemColor) -> void:
	modulate = property.value
	queue_redraw()
