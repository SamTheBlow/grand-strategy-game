class_name RandomGridWorld
extends GameGeneration
## Manipulates given raw data to generate new worlds with code.
## Populates it with province data,
## adds in some countries and places those countries on the map.

var grid_width: int = 1
var grid_height: int = 1
var number_of_countries: int = 2
var grid_shape_option: int = 0
var use_noise: bool = false
var noise_frequency: float = 1.0
var noise_threshold: float = 0.0


func apply(raw_data: Dictionary) -> void:
	super(raw_data)

	match grid_shape_option:
		0:
			HexGridGeneration.new().apply(
					raw_data,
					grid_width,
					grid_height,
					use_noise,
					noise_frequency,
					noise_threshold
			)
		1:
			SquareGridGeneration.new().apply(
					raw_data,
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

	CountryGeneration.new().apply(raw_data, number_of_countries)
	CountryPlacementGeneration.new().apply(raw_data)


func load_settings(settings: Dictionary) -> void:
	super(settings)

	# Load grid width
	if not ParseUtils.dictionary_has_dictionary(settings, "GRID_WIDTH"):
		error = true
		error_message = "No grid width found."
		return
	var setting_dict: Dictionary = settings["GRID_WIDTH"]
	if not ParseUtils.dictionary_has_number(
			setting_dict, ProjectSettingsNode.KEY_VALUE
	):
		error = true
		error_message = "No grid width found (the setting has no value)."
		return
	grid_width = (
			ParseUtils.dictionary_int(setting_dict, ProjectSettingsNode.KEY_VALUE)
	)

	# Load grid height
	if not ParseUtils.dictionary_has_dictionary(settings, "GRID_HEIGHT"):
		error = true
		error_message = "No grid height found."
		return
	setting_dict = settings["GRID_HEIGHT"]
	if not ParseUtils.dictionary_has_number(
			setting_dict, ProjectSettingsNode.KEY_VALUE
	):
		error = true
		error_message = "No grid height found (the setting has no value)."
		return
	grid_height = (
			ParseUtils.dictionary_int(setting_dict, ProjectSettingsNode.KEY_VALUE)
	)

	# Load number of countries
	if not ParseUtils.dictionary_has_dictionary(
			settings, "NUMBER_OF_COUNTRIES"
	):
		error = true
		error_message = "No number of countries found."
		return
	setting_dict = settings["NUMBER_OF_COUNTRIES"]
	if not ParseUtils.dictionary_has_number(
			setting_dict, ProjectSettingsNode.KEY_VALUE
	):
		error = true
		error_message = "No number of countries found (setting has no value)."
		return
	number_of_countries = (
			ParseUtils.dictionary_int(setting_dict, ProjectSettingsNode.KEY_VALUE)
	)

	# Load grid shape
	if not ParseUtils.dictionary_has_dictionary(settings, "GRID_SHAPE"):
		error = true
		error_message = "No grip shape found."
		return
	setting_dict = settings["GRID_SHAPE"]
	if not ParseUtils.dictionary_has_number(
			setting_dict, ProjectSettingsNode.KEY_VALUE
	):
		error = true
		error_message = "No grid shape found (setting has no value)."
		return
	grid_shape_option = (
			ParseUtils.dictionary_int(setting_dict, ProjectSettingsNode.KEY_VALUE)
	)

	# Load use_noise
	if not ParseUtils.dictionary_has_dictionary(settings, "USE_NOISE"):
		error = true
		error_message = "No use_noise setting found."
		return
	setting_dict = settings["USE_NOISE"]
	if not ParseUtils.dictionary_has_bool(
			setting_dict, ProjectSettingsNode.KEY_VALUE
	):
		error = true
		error_message = "No use_noise setting found (setting has no value)."
		return
	use_noise = setting_dict[ProjectSettingsNode.KEY_VALUE]

	# Load noise frequency
	if not ParseUtils.dictionary_has_dictionary(settings, "NOISE_FREQUENCY"):
		error = true
		error_message = "No noise frequency found."
		return
	setting_dict = settings["NOISE_FREQUENCY"]
	if not ParseUtils.dictionary_has_number(
			setting_dict, ProjectSettingsNode.KEY_VALUE
	):
		error = true
		error_message = "No noise frequency found (setting has no value)."
		return
	noise_frequency = (
			ParseUtils.dictionary_float(setting_dict, ProjectSettingsNode.KEY_VALUE)
	)

	# Load noise threshold
	if not ParseUtils.dictionary_has_dictionary(settings, "NOISE_THRESHOLD"):
		error = true
		error_message = "No noise threshold found."
		return
	setting_dict = settings["NOISE_THRESHOLD"]
	if not ParseUtils.dictionary_has_number(
			setting_dict, ProjectSettingsNode.KEY_VALUE
	):
		error = true
		error_message = "No noise threshold found (setting has no value)."
		return
	noise_threshold = (
			ParseUtils.dictionary_float(setting_dict, ProjectSettingsNode.KEY_VALUE)
	)
