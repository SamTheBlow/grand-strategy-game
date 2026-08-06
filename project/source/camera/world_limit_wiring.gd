class_name WorldLimitWiring
extends Node
## Provides position limits and zoom limits according to some [WorldLimits].

signal camera_moved(position: Vector2)
signal limits_changed(left: float, top: float, right: float, bottom: float)
signal zoom_limits_changed(minimum_zoom: float, maximum_zoom: float)

const _MAXIMUM_ZOOM: float = 1.0

var _world_limits: WorldLimits:
	set(value):
		if _world_limits != null:
			_world_limits.current_limits_changed.disconnect(_emit_values)

		_world_limits = value
		_emit_values()

		if _world_limits != null:
			_world_limits.current_limits_changed.connect(_emit_values.unbind(1))


func _ready() -> void:
	# The minimum zoom depends on the viewport size.
	get_viewport().size_changed.connect(_emit_zoom_limits)


func _on_world_loaded(world_visuals: WorldVisuals2D) -> void:
	_world_limits = world_visuals.project.game.world.limits()
	camera_moved.emit(_world_limits.center())


func _emit_values() -> void:
	_emit_limits()
	_emit_zoom_limits()


func _emit_limits() -> void:
	limits_changed.emit(
			float(_world_limits.limit_left()),
			float(_world_limits.limit_top()),
			float(_world_limits.limit_right()),
			float(_world_limits.limit_bottom())
	)


func _emit_zoom_limits() -> void:
	var minimum_zoom: float = _minimum_zoom()
	var maximum_zoom: float = maxf(_MAXIMUM_ZOOM, minimum_zoom)
	zoom_limits_changed.emit(minimum_zoom, maximum_zoom)


## Currently, you can zoom out such that the world takes half the screen.
func _minimum_zoom() -> float:
	if _world_limits == null:
		return -INF
	if _world_limits.width() == 0.0 or _world_limits.height() == 0.0:
		return -INF

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	return 0.5 * minf(
			viewport_size.x / _world_limits.width(),
			viewport_size.y / _world_limits.height()
	)
