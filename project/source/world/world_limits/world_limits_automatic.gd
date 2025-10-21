class_name WorldLimitsAutomatic
extends WorldLimits.WorldLimitsBase
## Determines its values based on given [GameWorld]'s contents.
## Automatically updates its values when the contents change.

## The amount of free space to add on each side, in pixels.
const _PADDING: int = 200

var _current_limits: Vector4i = WorldLimits.DEFAULT_LIMITS
var _game_world: GameWorld


func _init(game_world: GameWorld) -> void:
	_game_world = game_world
	# TODO listen to when a province's shape is changed
	_game_world.provinces.added.connect(_on_provinces_changed)
	_game_world.provinces.removed.connect(_on_provinces_changed)
	_update()


func value() -> Vector4i:
	return _current_limits


## If there is no data, applies the default world limits.
func _update() -> void:
	var no_data: bool = true
	var leftmost_point: float
	var rightmost_point: float
	var topmost_point: float
	var bottommost_point: float

	for province in _game_world.provinces.list():
		for vertex in province.polygon:
			var point_x: float = vertex.x + province.position.x
			var point_y: float = vertex.y + province.position.y

			# Initialization
			if no_data:
				leftmost_point = point_x
				rightmost_point = point_x
				topmost_point = point_y
				bottommost_point = point_y
				no_data = false
				continue

			if point_x < leftmost_point:
				leftmost_point = point_x
			elif point_x > rightmost_point:
				rightmost_point = point_x
			if point_y < topmost_point:
				topmost_point = point_y
			elif point_y > bottommost_point:
				bottommost_point = point_y

	var _old_values: Vector4i = _current_limits

	if no_data:
		_current_limits = WorldLimits.DEFAULT_LIMITS
	else:
		_current_limits = Vector4i(
				floori(leftmost_point - _PADDING),
				floori(topmost_point - _PADDING),
				floori(rightmost_point + _PADDING),
				floori(bottommost_point + _PADDING)
		)

	if _current_limits != _old_values:
		changed.emit()


func _on_provinces_changed(_province: Province) -> void:
	_update()
