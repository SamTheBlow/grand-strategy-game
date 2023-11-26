class_name WorldLimits
## Pretty much just a Rect2i.


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


static func from_json(json_data: Dictionary) -> WorldLimits:
	var x1: int = json_data["left"]
	var y1: int = json_data["top"]
	var x2: int = json_data["right"]
	var y2: int = json_data["bottom"]
	
	var world_limits := WorldLimits.new()
	world_limits._limits = Rect2i(x1, y1, x2 - x1, y2 - y1)
	return world_limits


func as_json() -> Dictionary:
	return {
		"top": limit_top(),
		"bottom": limit_bottom(),
		"left": limit_left(),
		"right": limit_right(),
	}
