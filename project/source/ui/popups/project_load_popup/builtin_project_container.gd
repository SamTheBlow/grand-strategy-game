class_name BuiltInProjectContainer
extends ProjectOptionContainer
## Automatically populates itself with existing built-in projects.

@export var _builtin_game_file_paths: Array[String]


func _ready() -> void:
	for project_file_path in _builtin_game_file_paths:
		var parse_result := MetadataBundle.from_path(project_file_path)
		if parse_result.error:
			continue
		add_option(parse_result.result)
