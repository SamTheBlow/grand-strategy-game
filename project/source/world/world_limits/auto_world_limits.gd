class_name AutoWorldLimits
## Automatically generates world limits for given [GameWorld].

## The amount of free space to add on each side, in pixels.
const PADDING: int = 200


## If world limits could not be determined, applies the default world limits.
## Modifies the values in given [WorldLimits]. Given [GameWorld] is untouched.
static func apply_to(game_world: GameWorld, world_limits: WorldLimits) -> void:
	var is_not_initialized: bool = true
	var leftmost_point: float
	var rightmost_point: float
	var topmost_point: float
	var bottommost_point: float

	for province in game_world.provinces.list():
		for vertex in province.polygon:
			var point_x: float = vertex.x + province.position.x
			var point_y: float = vertex.y + province.position.y

			# Initialization
			if is_not_initialized:
				leftmost_point = point_x
				rightmost_point = point_x
				topmost_point = point_y
				bottommost_point = point_y
				is_not_initialized = false
				continue

			if point_x < leftmost_point:
				leftmost_point = point_x
			elif point_x > rightmost_point:
				rightmost_point = point_x
			if point_y < topmost_point:
				topmost_point = point_y
			elif point_y > bottommost_point:
				bottommost_point = point_y

	if is_not_initialized:
		world_limits.reset()
		return

	world_limits.with_values(
			floori(leftmost_point - PADDING),
			floori(topmost_point - PADDING),
			floori(rightmost_point + PADDING),
			floori(bottommost_point + PADDING)
	)
