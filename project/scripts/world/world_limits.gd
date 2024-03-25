class_name WorldLimits
## Pretty much just a Rect2i.
## Currently, this class does not do anything that Rect2i can't do.
## But maybe it will in the future.


var _limits: Rect2i = Rect2i(0, 0, 10_000_000, 10_000_000)


func limit_top() -> int:
	return _limits.position.y


func limit_bottom() -> int:
	return _limits.end.y


func limit_left() -> int:
	return _limits.position.x


func limit_right() -> int:
	return _limits.end.x


static func from_rect2i(rect2i: Rect2i) -> WorldLimits:
	var world_limits := WorldLimits.new()
	world_limits._limits = rect2i
	return world_limits
