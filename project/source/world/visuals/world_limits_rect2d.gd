@tool
class_name WorldLimitsRect2D
extends Rect2D
## [Rect2D] that updates according to given settings and given limits.

@export var _setting_show_limits: ItemBool
@export var _setting_limits_color: ItemColor


func _ready() -> void:
	rectangle = Rect2(
			WorldLimits.DEFAULT_LEFT,
			WorldLimits.DEFAULT_TOP,
			WorldLimits.DEFAULT_RIGHT - WorldLimits.DEFAULT_LEFT,
			WorldLimits.DEFAULT_BOTTOM - WorldLimits.DEFAULT_TOP
	)

	if Engine.is_editor_hint():
		return

	_update_world_limits_visible(_setting_show_limits.value)
	_setting_show_limits.value_changed.connect(_update_world_limits_visible)
	_update_world_limits_color(_setting_limits_color.value)
	_setting_limits_color.value_changed.connect(_update_world_limits_color)


func set_limits(left: float, top: float, right: float, bottom: float) -> void:
	rectangle = Rect2(left, top, right - left, bottom - top)
	queue_redraw()


func _update_world_limits_visible(new_value: bool) -> void:
	visible = new_value


func _update_world_limits_color(new_value: Color) -> void:
	modulate = new_value
	queue_redraw()
