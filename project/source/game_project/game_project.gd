class_name GameProject
## Contains a game, its metadata, and more.
## Also contains useful functions.

var file_path_changed: Signal

var game := Game.new()
var textures := ProjectTextures.new(_absolute_file_path)
var metadata := ProjectMetadata.new()

var _absolute_file_path := StringRef.new()


func _init(absolute_file_path: String = "") -> void:
	_absolute_file_path.value = absolute_file_path
	file_path_changed = _absolute_file_path.changed


## Returns the absolute file path where this project is located.
func file_path() -> String:
	return _absolute_file_path.value


func set_file_path(value: String) -> void:
	_absolute_file_path.value = value


## In exported projects, file paths that start with "res://" are not valid.
func has_valid_file_path() -> bool:
	return _absolute_file_path.value != "" and not (
			not OS.has_feature("editor")
			and file_path().begins_with("res://")
	)
