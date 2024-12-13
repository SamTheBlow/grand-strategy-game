class_name HexGridGeneration
## Populates given JSON data with a hex grid world.
## Generates the province data and the world limits.

var world_limits_margin: float = 300.0
var hexagon_width: float = 200.0
var hexagon_height: float = 200.0
var hexagon_spacing_x: float = 16.0
var hexagon_spacing_y: float = 16.0


func apply(
		raw_data: Variant,
		grid_width: int,
		grid_height: int,
		use_noise: bool,
		noise_frequency: float,
		noise_threshold: float
) -> void:
	if raw_data is not Dictionary:
		return

	var provinces_array: Array
	if use_noise:
		provinces_array = _provinces_array_with_noise(
				grid_width, grid_height, noise_frequency, noise_threshold
		)
	else:
		provinces_array = _provinces_array_without_noise(
				grid_width, grid_height
		)

	var world_dict: Dictionary = {
		GameFromRawDict.WORLD_LIMITS_KEY: {
			GameFromRawDict.WORLD_LIMIT_BOTTOM_KEY: roundi(
					world_limits_margin * 2.0
					+ hexagon_height * 0.75 * grid_height
					+ hexagon_height * 0.25
					+ hexagon_spacing_y * (grid_height - 1)
			),
			GameFromRawDict.WORLD_LIMIT_LEFT_KEY: 0,
			GameFromRawDict.WORLD_LIMIT_RIGHT_KEY: roundi(
					world_limits_margin * 2.0
					+ hexagon_width * grid_width
					+ hexagon_spacing_x * (grid_width - 1)
			),
			GameFromRawDict.WORLD_LIMIT_TOP_KEY: 0,
		},
		GameFromRawDict.WORLD_PROVINCES_KEY: provinces_array,
	}

	var merge_dict: Dictionary = {GameFromRawDict.WORLD_KEY: world_dict}
	(raw_data as Dictionary).merge(merge_dict, true)


func _provinces_array_with_noise(
		grid_width: int,
		grid_height: int,
		noise_frequency: float,
		noise_threshold: float
) -> Array:
	# Generate perlin noise
	var perlin_noise := FastNoiseLite.new()
	perlin_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	perlin_noise.seed = randi()
	perlin_noise.frequency = noise_frequency

	var provinces_array: Array = []
	var province_id: int = 0
	var province_pos_x: float
	var province_pos_y: float = world_limits_margin
	var is_hex_tabbed: bool = false
	for j in grid_height:
		province_pos_x = world_limits_margin
		if is_hex_tabbed:
			province_pos_x += (hexagon_width + hexagon_spacing_x) * 0.5

		for i in grid_width:
			if not _is_province_real(perlin_noise, i, j, noise_threshold):
				province_id += 1
				province_pos_x += hexagon_width + hexagon_spacing_x
				continue

			var province_links: Array = []
			if i > 0 and _is_province_real(
					perlin_noise, i - 1, j, noise_threshold
			):
				province_links.append(province_id - 1)
			if i < grid_width - 1 and _is_province_real(
					perlin_noise, i + 1, j, noise_threshold
			):
				province_links.append(province_id + 1)

			if j > 0:
				if _is_province_real(perlin_noise, i, j - 1, noise_threshold):
					province_links.append(province_id - grid_width)

				if is_hex_tabbed and i < grid_width - 1 and _is_province_real(
						perlin_noise, i + 1, j - 1, noise_threshold
				):
					province_links.append(province_id - grid_width + 1)
				if not is_hex_tabbed and i > 0 and _is_province_real(
						perlin_noise, i - 1, j - 1, noise_threshold
				):
					province_links.append(province_id - grid_width - 1)
			if j < grid_height - 1:
				if _is_province_real(perlin_noise, i, j + 1, noise_threshold):
					province_links.append(province_id + grid_width)

				if is_hex_tabbed and i < grid_width - 1 and _is_province_real(
						perlin_noise, i + 1, j + 1, noise_threshold
				):
					province_links.append(province_id + grid_width + 1)
				if not is_hex_tabbed and i > 0 and _is_province_real(
						perlin_noise, i - 1, j + 1, noise_threshold
				):
					province_links.append(province_id + grid_width - 1)

			var province_shape_x: Array = [
				hexagon_width * 0.5,
				hexagon_width,
				hexagon_width,
				hexagon_width * 0.5,
				0,
				0,
			]
			var province_shape_y: Array = [
				0,
				hexagon_height * 0.25,
				hexagon_height * 0.75,
				hexagon_height,
				hexagon_height * 0.75,
				hexagon_height * 0.25,
			]

			var province_dict: Dictionary = {
				GameFromRawDict.PROVINCE_ID_KEY: province_id,
				GameFromRawDict.PROVINCE_LINKS_KEY: province_links,
				GameFromRawDict.PROVINCE_POSITION_KEY: {
					GameFromRawDict.PROVINCE_POS_X_KEY: province_pos_x,
					GameFromRawDict.PROVINCE_POS_Y_KEY: province_pos_y,
				},
				GameFromRawDict.PROVINCE_POSITION_ARMY_HOST_X_KEY: (
						province_pos_x + hexagon_width * 0.5
				),
				GameFromRawDict.PROVINCE_POSITION_ARMY_HOST_Y_KEY: (
						province_pos_y + hexagon_height * 0.5
				),
				GameFromRawDict.PROVINCE_SHAPE_KEY: {
					GameFromRawDict.PROVINCE_SHAPE_X_KEY: province_shape_x,
					GameFromRawDict.PROVINCE_SHAPE_Y_KEY: province_shape_y,
				},
			}

			provinces_array.append(province_dict)
			province_id += 1
			province_pos_x += hexagon_width + hexagon_spacing_x

		is_hex_tabbed = not is_hex_tabbed
		province_pos_y += hexagon_height * 0.75 + hexagon_spacing_y

	return provinces_array


func _provinces_array_without_noise(
		grid_width: int, grid_height: int
) -> Array:
	var provinces_array: Array = []
	var province_id: int = 0
	var province_pos_x: float
	var province_pos_y: float = world_limits_margin
	var is_hex_tabbed: bool = false
	for j in grid_height:
		province_pos_x = world_limits_margin
		if is_hex_tabbed:
			province_pos_x += (hexagon_width + hexagon_spacing_x) * 0.5

		for i in grid_width:
			var province_links: Array = []
			if i > 0:
				province_links.append(province_id - 1)
			if i < grid_width - 1:
				province_links.append(province_id + 1)

			if j > 0:
				province_links.append(province_id - grid_width)

				if is_hex_tabbed and i < grid_width - 1:
					province_links.append(province_id - grid_width + 1)
				if not is_hex_tabbed and i > 0:
					province_links.append(province_id - grid_width - 1)
			if j < grid_height - 1:
				province_links.append(province_id + grid_width)

				if is_hex_tabbed and i < grid_width - 1:
					province_links.append(province_id + grid_width + 1)
				if not is_hex_tabbed and i > 0:
					province_links.append(province_id + grid_width - 1)

			var province_shape_x: Array = [
				hexagon_width * 0.5,
				hexagon_width,
				hexagon_width,
				hexagon_width * 0.5,
				0,
				0,
			]
			var province_shape_y: Array = [
				0,
				hexagon_height * 0.25,
				hexagon_height * 0.75,
				hexagon_height,
				hexagon_height * 0.75,
				hexagon_height * 0.25,
			]

			var province_dict: Dictionary = {
				GameFromRawDict.PROVINCE_ID_KEY: province_id,
				GameFromRawDict.PROVINCE_LINKS_KEY: province_links,
				GameFromRawDict.PROVINCE_POSITION_KEY: {
					GameFromRawDict.PROVINCE_POS_X_KEY: province_pos_x,
					GameFromRawDict.PROVINCE_POS_Y_KEY: province_pos_y,
				},
				GameFromRawDict.PROVINCE_POSITION_ARMY_HOST_X_KEY: (
						province_pos_x + hexagon_width * 0.5
				),
				GameFromRawDict.PROVINCE_POSITION_ARMY_HOST_Y_KEY: (
						province_pos_y + hexagon_height * 0.5
				),
				GameFromRawDict.PROVINCE_SHAPE_KEY: {
					GameFromRawDict.PROVINCE_SHAPE_X_KEY: province_shape_x,
					GameFromRawDict.PROVINCE_SHAPE_Y_KEY: province_shape_y,
				},
			}

			provinces_array.append(province_dict)
			province_id += 1
			province_pos_x += hexagon_width + hexagon_spacing_x

		is_hex_tabbed = not is_hex_tabbed
		province_pos_y += hexagon_height * 0.75 + hexagon_spacing_y

	return provinces_array


func _is_province_real(
		noise: FastNoiseLite, x: int, y: int, noise_threshold: float
) -> bool:
	return noise.get_noise_2d(x, y) >= noise_threshold
