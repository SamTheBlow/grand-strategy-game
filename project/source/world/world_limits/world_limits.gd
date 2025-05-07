class_name WorldLimits
## The limits of a 2D world map.
## Represents how far the camera can go on each side of the map.

signal changed(this: WorldLimits)

const DEFAULT_LEFT: int = 0
const DEFAULT_TOP: int = 0
const DEFAULT_RIGHT: int = 10_000
const DEFAULT_BOTTOM: int = 10_000

var limit_left: int = DEFAULT_LEFT:
	set(value):
		limit_left = value
		changed.emit(self)

var limit_top: int = DEFAULT_TOP:
	set(value):
		limit_top = value
		changed.emit(self)

var limit_right: int = DEFAULT_RIGHT:
	set(value):
		limit_right = value
		changed.emit(self)

var limit_bottom: int = DEFAULT_BOTTOM:
	set(value):
		limit_bottom = value
		changed.emit(self)


## Sets each limit. Returns itself.
func with_values(left: int, top: int, right: int, bottom: int) -> WorldLimits:
	limit_left = left
	limit_top = top
	limit_right = right
	limit_bottom = bottom
	return self


func width() -> int:
	return limit_right - limit_left


func height() -> int:
	return limit_bottom - limit_top


## The middle point, rounded towards negative infinity.
func center() -> Vector2i:
	return Vector2i(
			limit_left + floori(width() * 0.5),
			limit_top + floori(height() * 0.5)
	)


func as_rect2i() -> Rect2i:
	return Rect2i(limit_left, limit_top, width(), height())


## Resets each limit to its default value.
func reset() -> void:
	limit_left = DEFAULT_LEFT
	limit_top = DEFAULT_TOP
	limit_right = DEFAULT_RIGHT
	limit_bottom = DEFAULT_BOTTOM
