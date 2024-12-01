class_name RandomFreeform
extends GameGeneration
## Takes given JSON data and populates it with a "freeform" map,
## adds in some countries and places those countries on the map.
##
## See also: [FreeformGeneration]


var grid_width: int = 1
var grid_height: int = 1
var number_of_countries: int = 2


func apply(raw_data: Dictionary) -> void:
	FreeformGeneration.new().apply(raw_data, grid_width, grid_height)
	CountryGeneration.new().apply(raw_data, number_of_countries)
	CountryPlacementGeneration.new().apply(raw_data)


func load_settings(map_settings: Dictionary) -> void:
	super(map_settings)

	# Load grid width
	if not ParseUtils.dictionary_has_dictionary(map_settings, "GRID_WIDTH"):
		error = true
		error_message = "No grid width found."
		return
	var setting_dict: Dictionary = map_settings["GRID_WIDTH"]
	if not ParseUtils.dictionary_has_number(
			setting_dict, MapSettings.KEY_VALUE
	):
		error = true
		error_message = "No grid width found (the setting has no value)."
		return
	grid_width = (
			ParseUtils.dictionary_int(setting_dict, MapSettings.KEY_VALUE)
	)

	# Load grid height
	if not ParseUtils.dictionary_has_dictionary(map_settings, "GRID_HEIGHT"):
		error = true
		error_message = "No grid height found."
		return
	setting_dict = map_settings["GRID_HEIGHT"]
	if not ParseUtils.dictionary_has_number(
			setting_dict, MapSettings.KEY_VALUE
	):
		error = true
		error_message = "No grid height found (the setting has no value)."
		return
	grid_height = (
			ParseUtils.dictionary_int(setting_dict, MapSettings.KEY_VALUE)
	)

	# Load number of countries
	if not ParseUtils.dictionary_has_dictionary(
			map_settings, "NUMBER_OF_COUNTRIES"
	):
		error = true
		error_message = "No number of countries found."
		return
	setting_dict = map_settings["NUMBER_OF_COUNTRIES"]
	if not ParseUtils.dictionary_has_number(
			setting_dict, MapSettings.KEY_VALUE
	):
		error = true
		error_message = "No number of countries found (setting has no value)."
		return
	number_of_countries = (
			ParseUtils.dictionary_int(setting_dict, MapSettings.KEY_VALUE)
	)
