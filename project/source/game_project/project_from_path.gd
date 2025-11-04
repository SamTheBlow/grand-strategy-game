class_name ProjectFromPath
## Loads a [GameProject] from given file path.


static func loaded_from(file_path: String) -> ProjectParsing.ParseResult:
	var file_json := FileJSON.new()
	file_json.load_json(file_path)
	if file_json.error:
		return ProjectParsing.ResultError.new(file_json.error_message)

	return ProjectParsing.parsed_from(file_json.result, file_path)


static func generated_from(
		metadata_bundle: MetadataBundle, game_rules: GameRules
) -> ProjectParsing.ParseResult:
	var file_json := FileJSON.new()
	file_json.load_json(metadata_bundle.project_absolute_path)
	if file_json.error:
		return ProjectParsing.ResultError.new(file_json.error_message)

	return ProjectParsing.generated_from(
			file_json.result, metadata_bundle, game_rules
	)
