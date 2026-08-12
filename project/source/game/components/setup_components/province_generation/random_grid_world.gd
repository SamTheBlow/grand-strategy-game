class_name RandomGridWorld
extends GameComponent
## Generates a new world with code. Populates given [Game] with provinces,
## adds in some countries and places those countries on the world map.

const _GRID_WIDTH_KEY: String = "grid_width"
const _GRID_HEIGHT_KEY: String = "grid_height"
const _NUMBER_OF_COUNTRIES_KEY: String = "number_of_countries"
const _GRID_SHAPE_KEY: String = "grid_shape"
const _USE_NOISE_KEY: String = "use_noise"
const _NOISE_FREQUENCY_KEY: String = "noise_frequency"
const _NOISE_THRESHOLD_KEY: String = "noise_threshold"

var grid_width: int = 2
var grid_height: int = 2
var number_of_countries: int = 2
var grid_shape_option: int = 0
var use_noise: bool = false
var noise_frequency: float = 1.0
var noise_threshold: float = 0.0


func run(game: Game) -> void:
	match grid_shape_option:
		0:
			HexGridGeneration.new().apply(
					game,
					grid_width,
					grid_height,
					use_noise,
					noise_frequency,
					noise_threshold
			)
		1:
			SquareGridGeneration.new().apply(
					game,
					grid_width,
					grid_height,
					use_noise,
					noise_frequency,
					noise_threshold
			)
		_:
			error = true
			error_message = "Unrecognized grid shape option."
			return

	CountryGeneration.apply(game, number_of_countries)
	CountryPlacementGeneration.apply(game)


func to_raw_data() -> Dictionary:
	return {
		_ID_KEY: _id(),
		_GRID_WIDTH_KEY: grid_width,
		_GRID_HEIGHT_KEY: grid_height,
		_NUMBER_OF_COUNTRIES_KEY: number_of_countries,
		_GRID_SHAPE_KEY: grid_shape_option,
		_USE_NOISE_KEY: use_noise,
		_NOISE_FREQUENCY_KEY: noise_frequency,
		_NOISE_THRESHOLD_KEY: noise_threshold,
	}


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _GRID_WIDTH_KEY):
		grid_width = ParseUtils.dictionary_int(raw_dict, _GRID_WIDTH_KEY)

	if ParseUtils.dictionary_has_number(raw_dict, _GRID_HEIGHT_KEY):
		grid_height = ParseUtils.dictionary_int(raw_dict, _GRID_HEIGHT_KEY)

	if ParseUtils.dictionary_has_number(raw_dict, _NUMBER_OF_COUNTRIES_KEY):
		number_of_countries = ParseUtils.dictionary_int(
				raw_dict, _NUMBER_OF_COUNTRIES_KEY
		)

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

	error = false
	error_message = ""


func _id() -> int:
	return 0
