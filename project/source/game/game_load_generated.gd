class_name GameLoadGenerated
## Loads a [Game] from given [MapMetadata].
## Generates the world, countries, etc. Then, populates the data
## using given generation settings (see [PopulatedSaveFile]).


var error: bool = true
var error_message: String = ""
var result: Game


func load_game(map_metadata: MapMetadata, generation_settings: GameRules) -> void:
	# Load the file
	var file_json := FileJSON.new()
	file_json.load_json(map_metadata.file_path)
	if file_json.error:
		error = true
		error_message = file_json.error_message
		return
	
	# Generate data
	var map_settings: Dictionary = map_metadata.settings
	var random_hex_grid := RandomHexGrid.new()
	
	if not ParseUtils.dictionary_has_dictionary(map_settings, "GRID_WIDTH"):
		error = true
		error_message = "No grid width found."
		return
	var setting_dict: Dictionary = map_settings["GRID_WIDTH"]
	if not ParseUtils.dictionary_has_number(setting_dict, MapSettings.KEY_VALUE):
		error = true
		error_message = "No grid width found (the setting has no value)."
		return
	random_hex_grid.grid_width = (
			ParseUtils.dictionary_int(setting_dict, MapSettings.KEY_VALUE)
	)
	
	if not ParseUtils.dictionary_has_dictionary(map_settings, "GRID_HEIGHT"):
		error = true
		error_message = "No grid height found."
		return
	setting_dict = map_settings["GRID_HEIGHT"]
	if not ParseUtils.dictionary_has_number(setting_dict, MapSettings.KEY_VALUE):
		error = true
		error_message = "No grid height found (the setting has no value)."
		return
	random_hex_grid.grid_height = (
			ParseUtils.dictionary_int(setting_dict, MapSettings.KEY_VALUE)
	)
	
	if not ParseUtils.dictionary_has_dictionary(
			map_settings, "NUMBER_OF_COUNTRIES"
	):
		error = true
		error_message = "No number of countries found."
		return
	setting_dict = map_settings["NUMBER_OF_COUNTRIES"]
	if not ParseUtils.dictionary_has_number(setting_dict, MapSettings.KEY_VALUE):
		error = true
		error_message = "No number of countries found (setting has no value)."
		return
	random_hex_grid.number_of_countries = (
			ParseUtils.dictionary_int(setting_dict, MapSettings.KEY_VALUE)
	)
	
	random_hex_grid.apply(file_json.result)
	
	# Modify the JSON data
	var populated_save_file := PopulatedSaveFile.new()
	populated_save_file.apply(file_json.result, generation_settings)
	if populated_save_file.error:
		error = true
		error_message = populated_save_file.error_message
		return
	
	# Load the game using the modified JSON data
	var game_from_raw := GameFromRawDict.new()
	game_from_raw.load_game(populated_save_file.result)
	if game_from_raw.error:
		error = true
		error_message = game_from_raw.error_message
		return
	
	# Success!
	error = false
	result = game_from_raw.result
