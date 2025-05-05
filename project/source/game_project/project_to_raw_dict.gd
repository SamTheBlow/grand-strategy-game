class_name ProjectToRawDict
## Converts a [GameProject] into a raw [Dictionary].
##
## See also: [ProjectFromRaw]

var result: Dictionary


func convert_project(project: GameProject) -> void:
	var game_to_raw_dict := GameToRawDict.new()
	game_to_raw_dict.convert_game(project.game, project.settings)

	var output: Dictionary = game_to_raw_dict.result
	output[GameMetadata.KEY_METADATA] = project.metadata.to_dict_save_file()

	var custom_settings: Dictionary = project.settings.to_dict()
	if not custom_settings.is_empty():
		output[GameMetadata.KEY_METADATA][GameMetadata.KEY_META_SETTINGS] = (
				custom_settings
		)

	result = output
