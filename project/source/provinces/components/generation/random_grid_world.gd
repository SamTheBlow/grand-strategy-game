class_name RandomGridWorld
extends GameComponent
## Generates a game's provinces with code.

const KEY: String = "random_grid_world"

const _GRID_WIDTH_KEY: String = "grid_width"
const _GRID_HEIGHT_KEY: String = "grid_height"
const _GRID_SHAPE_KEY: String = "grid_shape"
const _USE_NOISE_KEY: String = "use_noise"
const _NOISE_FREQUENCY_KEY: String = "noise_frequency"
const _NOISE_THRESHOLD_KEY: String = "noise_threshold"
const _PROVINCE_DATA_KEY: String = "province_data"

var grid_width: int = 1
var grid_height: int = 1
var grid_shape_option: int = 0
var use_noise: bool = false
var noise_frequency: float = 1.0
var noise_threshold: float = 0.0

## Province raw data. Used as a blueprint for newly generated provinces.
var province_data: Dictionary = {}


func _init() -> void:
	priority_index = 4


func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	match grid_shape_option:
		0:
			HexGridGeneration.new().apply(
					game,
					grid_width,
					grid_height,
					use_noise,
					noise_frequency,
					noise_threshold,
					province_data
			)
		1:
			SquareGridGeneration.new().apply(
					game,
					grid_width,
					grid_height,
					use_noise,
					noise_frequency,
					noise_threshold,
					province_data
			)
		_:
			error = true
			error_message = "Unrecognized grid shape option."
			return


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if grid_width != 1:
		output[_GRID_WIDTH_KEY] = grid_width
	if grid_height != 1:
		output[_GRID_HEIGHT_KEY] = grid_height
	if grid_shape_option != 0:
		output[_GRID_SHAPE_KEY] = grid_shape_option
	if use_noise:
		output[_USE_NOISE_KEY] = use_noise
	if noise_frequency != 1.0:
		output[_NOISE_FREQUENCY_KEY] = noise_frequency
	if noise_threshold != 0.0:
		output[_NOISE_THRESHOLD_KEY] = noise_threshold
	if not province_data.is_empty():
		output[_PROVINCE_DATA_KEY] = province_data
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _GRID_WIDTH_KEY):
		grid_width = ParseUtils.dictionary_int(raw_dict, _GRID_WIDTH_KEY)

	if ParseUtils.dictionary_has_number(raw_dict, _GRID_HEIGHT_KEY):
		grid_height = ParseUtils.dictionary_int(raw_dict, _GRID_HEIGHT_KEY)

	if ParseUtils.dictionary_has_number(raw_dict, _GRID_SHAPE_KEY):
		grid_shape_option = ParseUtils.dictionary_int(
				raw_dict, _GRID_SHAPE_KEY
		)

	if ParseUtils.dictionary_has_bool(raw_dict, _USE_NOISE_KEY):
		use_noise = raw_dict[_USE_NOISE_KEY]

	if ParseUtils.dictionary_has_number(raw_dict, _NOISE_FREQUENCY_KEY):
		noise_frequency = ParseUtils.dictionary_float(
				raw_dict, _NOISE_FREQUENCY_KEY
		)

	if ParseUtils.dictionary_has_number(raw_dict, _NOISE_THRESHOLD_KEY):
		noise_threshold = ParseUtils.dictionary_float(
				raw_dict, _NOISE_THRESHOLD_KEY
		)

	if ParseUtils.dictionary_has_dictionary(raw_dict, _PROVINCE_DATA_KEY):
		province_data = raw_dict[_PROVINCE_DATA_KEY]

	error = false
	error_message = ""
