class_name ProjectToRawDict
## Converts a [GameProject] into a raw [Dictionary].
##
## See also: [ProjectFromRaw]

var result: Dictionary


func convert_project(project: GameProject) -> void:
	var game_to_raw_dict := GameToRawDict.new()
	game_to_raw_dict.convert_game(project.game, project.settings)

	var output: Dictionary = game_to_raw_dict.result
	output[GameMetadata.KEY_METADATA] = project.metadata.to_dict(false)

	output[GameMetadata.KEY_METADATA][GameMetadata.KEY_META_SETTINGS] = (
			project.settings.to_dict()
	)

	result = output
