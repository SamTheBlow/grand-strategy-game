class_name ProjectToRawDict
## Converts a [GameProject] into a raw [Dictionary].
##
## See also: [ProjectFromRaw]


static func result(project: GameProject) -> Dictionary:
	var output: Dictionary = {
		ProjectFromRaw.VERSION_KEY: ProjectFromRaw.SAVE_DATA_VERSION,
	}

	# Game
	var game_dict: Dictionary = (
			GameParsing.game_to_raw_dict(project.game, project.settings)
	)
	if not game_dict.is_empty():
		output.merge(game_dict)

	# Textures
	var texture_data: Array = (
			ProjectTextureParsing.textures_to_raw_array(project.textures, true)
	)
	if not texture_data.is_empty():
		output.merge({ ProjectFromRaw.TEXTURES_KEY: texture_data })

	# Metadata
	var metadata_dict: Dictionary = project.metadata.to_dict_save_file()
	if not metadata_dict.is_empty():
		output.merge({ ProjectMetadata.KEY_METADATA: metadata_dict })

	# Settings
	var custom_settings: Dictionary = project.settings.to_dict()
	if not custom_settings.is_empty():
		output[ProjectMetadata.KEY_METADATA][ProjectMetadata.KEY_META_SETTINGS] = custom_settings

	return output
