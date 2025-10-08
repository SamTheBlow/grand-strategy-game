class_name ProjectToRawDict
## Converts a [GameProject] into a raw [Dictionary].
##
## See also: [ProjectFromRaw]


static func result(project: GameProject) -> Dictionary:
	var output: Dictionary = (
			GameToRawDict.result(project.game, project.settings)
	)
	output[ProjectFromRaw.VERSION_KEY] = ProjectFromRaw.SAVE_DATA_VERSION
	output[GameMetadata.KEY_METADATA] = project.metadata.to_dict_save_file()

	var custom_settings: Dictionary = project.settings.to_dict()
	if not custom_settings.is_empty():
		output[GameMetadata.KEY_METADATA][GameMetadata.KEY_META_SETTINGS] = (
				custom_settings
		)

	return output
