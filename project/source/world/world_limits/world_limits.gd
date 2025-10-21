class_name WorldLimits
## The limits of a 2D world map.
## Represents how far the camera can go on each side of the map.

signal current_limits_changed(this: WorldLimits)
signal custom_limits_changed(this: WorldLimits)

const DEFAULT_LEFT: int = 0
const DEFAULT_TOP: int = 0
const DEFAULT_RIGHT: int = 10_000
const DEFAULT_BOTTOM: int = 10_000
const DEFAULT_LIMITS := Vector4i(
		DEFAULT_LEFT, DEFAULT_TOP, DEFAULT_RIGHT, DEFAULT_BOTTOM
)

var _custom_limits_enabled: bool = true

## x = left, y = top, z = right, w = bottom
var custom_limits: Vector4i = DEFAULT_LIMITS:
	set(value):
		if custom_limits == value:
			return
		custom_limits = value
		custom_limits_changed.emit(self)

var _current_limits: WorldLimitsBase:
	set(value):
		if _current_limits != null:
			_current_limits.changed.disconnect(current_limits_changed.emit)
		_current_limits = value
		_current_limits.changed.connect(current_limits_changed.emit.bind(self))


func _init() -> void:
	# Trigger the setter
	_current_limits = WorldLimitsCustom.new(self)


func is_custom_limits_enabled() -> bool:
	return _custom_limits_enabled


func enable_custom_limits() -> void:
	var _old_limits: Vector4i = _current_limits.value()
	_current_limits = WorldLimitsCustom.new(self)
	_custom_limits_enabled = true
	if _old_limits != _current_limits.value():
		current_limits_changed.emit(self)


func disable_custom_limits(game_world: GameWorld) -> void:
	var _old_limits: Vector4i = _current_limits.value()
	_current_limits = WorldLimitsAutomatic.new(game_world)
	_custom_limits_enabled = false
	if _old_limits != _current_limits.value():
		current_limits_changed.emit(self)


func current_limits() -> Vector4i:
	return _current_limits.value()


func limit_left() -> int:
	return _current_limits.value().x


func limit_top() -> int:
	return _current_limits.value().y


func limit_right() -> int:
	return _current_limits.value().z


func limit_bottom() -> int:
	return _current_limits.value().w


func width() -> int:
	return limit_right() - limit_left()


func height() -> int:
	return limit_bottom() - limit_top()


## The middle point, rounded towards negative infinity.
func center() -> Vector2i:
	return Vector2i(
			limit_left() + floori(width() * 0.5),
			limit_top() + floori(height() * 0.5)
	)


func as_rect2i() -> Rect2i:
	return Rect2i(limit_left(), limit_top(), width(), height())


func to_raw_data() -> Variant:
	return WorldLimitsParsing.to_raw_data(self)


@abstract class WorldLimitsBase:
	signal changed()

	@abstract func value() -> Vector4i


class WorldLimitsCustom extends WorldLimitsBase:
	var _world_limits: WorldLimits

	func _init(world_limits: WorldLimits) -> void:
		_world_limits = world_limits
		_world_limits.custom_limits_changed.connect(_on_custom_limits_changed)

	func value() -> Vector4i:
		return _world_limits.custom_limits

	func _on_custom_limits_changed(_limits: WorldLimits) -> void:
		changed.emit()
