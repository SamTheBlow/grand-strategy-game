class_name WorldLimitsToRaw
## Converts a [WorldLimits] object into raw data.


## This operation always succeeds.
static func result(world_limits: WorldLimits) -> Dictionary:
	var raw_world_limits: Dictionary = {
		WorldLimitsFromRaw.WORLD_LIMIT_TOP_KEY: world_limits.limit_top,
		WorldLimitsFromRaw.WORLD_LIMIT_BOTTOM_KEY: world_limits.limit_bottom,
		WorldLimitsFromRaw.WORLD_LIMIT_LEFT_KEY: world_limits.limit_left,
		WorldLimitsFromRaw.WORLD_LIMIT_RIGHT_KEY: world_limits.limit_right,
	}

	if world_limits.limit_top == WorldLimits.DEFAULT_TOP:
		raw_world_limits.erase(WorldLimitsFromRaw.WORLD_LIMIT_TOP_KEY)
	if world_limits.limit_bottom == WorldLimits.DEFAULT_BOTTOM:
		raw_world_limits.erase(WorldLimitsFromRaw.WORLD_LIMIT_BOTTOM_KEY)
	if world_limits.limit_left == WorldLimits.DEFAULT_LEFT:
		raw_world_limits.erase(WorldLimitsFromRaw.WORLD_LIMIT_LEFT_KEY)
	if world_limits.limit_right == WorldLimits.DEFAULT_RIGHT:
		raw_world_limits.erase(WorldLimitsFromRaw.WORLD_LIMIT_RIGHT_KEY)

	return raw_world_limits
