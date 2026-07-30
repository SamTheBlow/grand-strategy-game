class_name TextureFromFilePath
extends TextureFromId

var _texture_absolute_path: String


func _init(texture_path: String, project_textures: ProjectTextures) -> void:
	_project_textures = project_textures

	if texture_path.is_absolute_path():
		_texture_absolute_path = texture_path
	else:
		_texture_absolute_path = ProjectTextures.texture_path_made_absolute(
				_project_textures.project_absolute_path_ref().value,
				texture_path
		)

	_id = _project_textures.new_id_from_file_path(_texture_absolute_path)


func absolute_path() -> String:
	return _texture_absolute_path


## Returns the texture's absolute path unchanged
## if the project's absolute path is empty or invalid.
func relative_path() -> String:
	var project_path: String = (
			_project_textures.project_absolute_path_ref().value
	)
	if project_path.begins_with("res://"):
		push_warning("Project path is an internal file.")
		return _texture_absolute_path

	return FileUtils.path_made_relative(project_path, _texture_absolute_path)
