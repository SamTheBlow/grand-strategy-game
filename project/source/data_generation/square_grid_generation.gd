class_name SquareGridGeneration
## Populates given JSON data with a square grid world.
## Generates the province data and the world limits.

var world_limits_margin: float = 300.0
var square_length: float = 200.0
var square_spacing: float = 16.0


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
		WorldFromRaw.WORLD_LIMITS_KEY: {
			WorldLimitsFromRaw.WORLD_LIMIT_BOTTOM_KEY: roundi(
					world_limits_margin * 2.0
					+ square_length * grid_height
					+ square_spacing * (grid_height - 1)
			),
			WorldLimitsFromRaw.WORLD_LIMIT_LEFT_KEY: 0,
			WorldLimitsFromRaw.WORLD_LIMIT_RIGHT_KEY: roundi(
					world_limits_margin * 2.0
					+ square_length * grid_width
					+ square_spacing * (grid_width - 1)
			),
			WorldLimitsFromRaw.WORLD_LIMIT_TOP_KEY: 0,
		},
		WorldFromRaw.WORLD_PROVINCES_KEY: provinces_array,
	}

	var merge_dict: Dictionary = { GameParsing._WORLD_KEY: world_dict }
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
	for j in grid_height:
		province_pos_x = world_limits_margin

		for i in grid_width:
			if not _is_province_real(perlin_noise, i, j, noise_threshold):
				province_id += 1
				province_pos_x += square_length + square_spacing
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
			if j > 0 and _is_province_real(
					perlin_noise, i, j - 1, noise_threshold
			):
				province_links.append(province_id - grid_width)
			if j < grid_height - 1 and _is_province_real(
					perlin_noise, i, j + 1, noise_threshold
			):
				province_links.append(province_id + grid_width)

			var province_shape_x: Array = [
				0,
				square_length,
				square_length,
				0,
			]
			var province_shape_y: Array = [
				0,
				0,
				square_length,
				square_length,
			]

			var province_dict: Dictionary = {
				ProvincesFromRaw.PROVINCE_ID_KEY: province_id,
				ProvincesFromRaw.PROVINCE_LINKS_KEY: province_links,
				ProvincesFromRaw.PROVINCE_POSITION_KEY: {
					ProvincesFromRaw.PROVINCE_POS_X_KEY: province_pos_x,
					ProvincesFromRaw.PROVINCE_POS_Y_KEY: province_pos_y,
				},
				ProvincesFromRaw.PROVINCE_POSITION_ARMY_HOST_X_KEY: (
						province_pos_x + square_length * 0.5
				),
				ProvincesFromRaw.PROVINCE_POSITION_ARMY_HOST_Y_KEY: (
						province_pos_y + square_length * 0.5
				),
				ProvincesFromRaw.PROVINCE_SHAPE_KEY: {
					ProvincesFromRaw.PROVINCE_SHAPE_X_KEY: province_shape_x,
					ProvincesFromRaw.PROVINCE_SHAPE_Y_KEY: province_shape_y,
				},
			}

			provinces_array.append(province_dict)
			province_id += 1
			province_pos_x += square_length + square_spacing

		province_pos_y += square_length + square_spacing

	return provinces_array


func _provinces_array_without_noise(
		grid_width: int, grid_height: int
) -> Array:
	var provinces_array: Array = []
	var province_id: int = 0
	var province_pos_x: float
	var province_pos_y: float = world_limits_margin
	for j in grid_height:
		province_pos_x = world_limits_margin

		for i in grid_width:
			var province_links: Array = []
			if i > 0:
				province_links.append(province_id - 1)
			if i < grid_width - 1:
				province_links.append(province_id + 1)
			if j > 0:
				province_links.append(province_id - grid_width)
			if j < grid_height - 1:
				province_links.append(province_id + grid_width)

			var province_shape_x: Array = [
				0,
				square_length,
				square_length,
				0,
			]
			var province_shape_y: Array = [
				0,
				0,
				square_length,
				square_length,
			]

			var province_dict: Dictionary = {
				ProvincesFromRaw.PROVINCE_ID_KEY: province_id,
				ProvincesFromRaw.PROVINCE_LINKS_KEY: province_links,
				ProvincesFromRaw.PROVINCE_POSITION_KEY: {
					ProvincesFromRaw.PROVINCE_POS_X_KEY: province_pos_x,
					ProvincesFromRaw.PROVINCE_POS_Y_KEY: province_pos_y,
				},
				ProvincesFromRaw.PROVINCE_POSITION_ARMY_HOST_X_KEY: (
						province_pos_x + square_length * 0.5
				),
				ProvincesFromRaw.PROVINCE_POSITION_ARMY_HOST_Y_KEY: (
						province_pos_y + square_length * 0.5
				),
				ProvincesFromRaw.PROVINCE_SHAPE_KEY: {
					ProvincesFromRaw.PROVINCE_SHAPE_X_KEY: province_shape_x,
					ProvincesFromRaw.PROVINCE_SHAPE_Y_KEY: province_shape_y,
				},
			}

			provinces_array.append(province_dict)
			province_id += 1
			province_pos_x += square_length + square_spacing

		province_pos_y += square_length + square_spacing

	return provinces_array


func _is_province_real(
		noise: FastNoiseLite, x: int, y: int, noise_threshold: float
) -> bool:
	return noise.get_noise_2d(x, y) >= noise_threshold
