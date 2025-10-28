class_name HexGridGeneration
## Populates given [Game] with a hex grid world.

var world_limits_margin: float = 300.0
var hexagon_width: float = 200.0
var hexagon_height: float = 200.0
var hexagon_spacing_x: float = 16.0
var hexagon_spacing_y: float = 16.0


func apply(
		game: Game,
		grid_width: int,
		grid_height: int,
		use_noise: bool,
		noise_frequency: float,
		noise_threshold: float
) -> void:
	game.world.provinces.clear()

	if use_noise:
		_generate_provinces_with_noise(
				game, grid_width, grid_height, noise_frequency, noise_threshold
		)
	else:
		_generate_provinces_without_noise(game, grid_width, grid_height)

	game.world.limits().disable_custom_limits()


func _generate_provinces_with_noise(
		game: Game,
		grid_width: int,
		grid_height: int,
		noise_frequency: float,
		noise_threshold: float
) -> void:
	# Generate perlin noise
	var perlin_noise := FastNoiseLite.new()
	perlin_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	perlin_noise.seed = randi()
	perlin_noise.frequency = noise_frequency

	var province_id: int = 0
	var province_position := Vector2(0.0, world_limits_margin)
	var is_hex_tabbed: bool = false
	for j in grid_height:
		province_position.x = world_limits_margin
		if is_hex_tabbed:
			province_position.x += (hexagon_width + hexagon_spacing_x) * 0.5

		for i in grid_width:
			if not _is_province_real(perlin_noise, i, j, noise_threshold):
				province_id += 1
				province_position.x += hexagon_width + hexagon_spacing_x
				continue

			var province := Province.new()
			province.id = province_id
			province.position_army_host = province_position + 0.5 * Vector2(
					hexagon_width, hexagon_height
			)

			# Province shape
			province.polygon().array = PackedVector2Array([
				province_position + Vector2(hexagon_width * 0.5, 0.0),
				province_position + Vector2(
						hexagon_width, hexagon_height * 0.25
				),
				province_position + Vector2(
						hexagon_width, hexagon_height * 0.75
				),
				province_position + Vector2(
						hexagon_width * 0.5, hexagon_height
				),
				province_position + Vector2(0.0, hexagon_height * 0.75),
				province_position + Vector2(0.0, hexagon_height * 0.25),
			])

			# Adjacencies
			if i > 0 and _is_province_real(
					perlin_noise, i - 1, j, noise_threshold
			):
				province.add_link(province_id - 1)
			if i < grid_width - 1 and _is_province_real(
					perlin_noise, i + 1, j, noise_threshold
			):
				province.add_link(province_id + 1)

			if j > 0:
				if _is_province_real(perlin_noise, i, j - 1, noise_threshold):
					province.add_link(province_id - grid_width)

				if is_hex_tabbed and i < grid_width - 1 and _is_province_real(
						perlin_noise, i + 1, j - 1, noise_threshold
				):
					province.add_link(province_id - grid_width + 1)
				if not is_hex_tabbed and i > 0 and _is_province_real(
						perlin_noise, i - 1, j - 1, noise_threshold
				):
					province.add_link(province_id - grid_width - 1)
			if j < grid_height - 1:
				if _is_province_real(perlin_noise, i, j + 1, noise_threshold):
					province.add_link(province_id + grid_width)

				if is_hex_tabbed and i < grid_width - 1 and _is_province_real(
						perlin_noise, i + 1, j + 1, noise_threshold
				):
					province.add_link(province_id + grid_width + 1)
				if not is_hex_tabbed and i > 0 and _is_province_real(
						perlin_noise, i - 1, j + 1, noise_threshold
				):
					province.add_link(province_id + grid_width - 1)

			game.world.provinces.add(province)
			province_id += 1
			province_position.x += hexagon_width + hexagon_spacing_x

		is_hex_tabbed = not is_hex_tabbed
		province_position.y += hexagon_height * 0.75 + hexagon_spacing_y


func _generate_provinces_without_noise(
		game: Game, grid_width: int, grid_height: int
) -> void:
	var province_id: int = 0
	var province_position := Vector2(0.0, world_limits_margin)
	var is_hex_tabbed: bool = false
	for j in grid_height:
		province_position.x = world_limits_margin
		if is_hex_tabbed:
			province_position.x += (hexagon_width + hexagon_spacing_x) * 0.5

		for i in grid_width:
			var province := Province.new()
			province.id = province_id
			province.position_army_host = province_position + 0.5 * Vector2(
					hexagon_width, hexagon_height
			)

			# Province shape
			province.polygon().array = PackedVector2Array([
				province_position + Vector2(hexagon_width * 0.5, 0.0),
				province_position + Vector2(
						hexagon_width, hexagon_height * 0.25
				),
				province_position + Vector2(
						hexagon_width, hexagon_height * 0.75
				),
				province_position + Vector2(
						hexagon_width * 0.5, hexagon_height
				),
				province_position + Vector2(0.0, hexagon_height * 0.75),
				province_position + Vector2(0.0, hexagon_height * 0.25),
			])

			# Adjacencies
			if i > 0:
				province.add_link(province_id - 1)
			if i < grid_width - 1:
				province.add_link(province_id + 1)

			if j > 0:
				province.add_link(province_id - grid_width)

				if is_hex_tabbed and i < grid_width - 1:
					province.add_link(province_id - grid_width + 1)
				if not is_hex_tabbed and i > 0:
					province.add_link(province_id - grid_width - 1)
			if j < grid_height - 1:
				province.add_link(province_id + grid_width)

				if is_hex_tabbed and i < grid_width - 1:
					province.add_link(province_id + grid_width + 1)
				if not is_hex_tabbed and i > 0:
					province.add_link(province_id + grid_width - 1)

			game.world.provinces.add(province)
			province_id += 1
			province_position.x += hexagon_width + hexagon_spacing_x

		is_hex_tabbed = not is_hex_tabbed
		province_position.y += hexagon_height * 0.75 + hexagon_spacing_y


func _is_province_real(
		noise: FastNoiseLite, x: int, y: int, noise_threshold: float
) -> bool:
	return noise.get_noise_2d(x, y) >= noise_threshold
