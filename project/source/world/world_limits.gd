class_name WorldLimits
## The limits of a 2D world map.
##
## See also: [GameWorld2D]

const DEFAULT_TOP: int = 0
const DEFAULT_BOTTOM: int = 10_000
const DEFAULT_LEFT: int = 0
const DEFAULT_RIGHT: int = 10_000

var _limits := Rect2i(
		DEFAULT_LEFT,
		DEFAULT_TOP,
		DEFAULT_RIGHT - DEFAULT_LEFT,
		DEFAULT_BOTTOM - DEFAULT_TOP
)


func limit_top() -> int:
	return _limits.position.y


func limit_bottom() -> int:
	return _limits.end.y


func limit_left() -> int:
	return _limits.position.x


func limit_right() -> int:
	return _limits.end.x


func width() -> int:
	return _limits.end.x - _limits.position.x


func height() -> int:
	return _limits.end.y - _limits.position.y


static func from_rect2i(rect2i: Rect2i) -> WorldLimits:
	var world_limits := WorldLimits.new()
	world_limits._limits = rect2i
	return world_limits
