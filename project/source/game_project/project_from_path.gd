class_name ProjectFromPath
## Loads a [GameProject] from given file path.


static func loaded_from(file_path: String) -> ProjectFromRaw.ParseResult:
	var file_json := FileJSON.new()
	file_json.load_json(file_path)
	if file_json.error:
		return ProjectFromRaw.ResultError.new(file_json.error_message)

	return ProjectFromRaw.parsed_from(file_json.result, file_path)
