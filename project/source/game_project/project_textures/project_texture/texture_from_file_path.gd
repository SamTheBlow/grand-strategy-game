class_name TextureFromFilePath
extends TextureFromId

var _texture_absolute_path: String
var _project_absolute_path: StringRef


func _init(
		texture_path: String, project_absolute_path: StringRef
) -> void:
	if texture_path.is_absolute_path():
		_texture_absolute_path = texture_path
	else:
		_texture_absolute_path = ProjectTextures.texture_path_made_absolute(
				project_absolute_path.value, texture_path
		)
	_project_absolute_path = project_absolute_path


func texture(
		textures: ProjectTextures, fallback_texture: Texture2D = null
) -> Texture2D:
	if _id < 0:
		_id = textures.new_id_from_file_path(_texture_absolute_path)

	return super(textures, fallback_texture)


func to_raw_data() -> Variant:
	if _id < 0:
		return _relative_path()

	return super()


func absolute_path() -> String:
	return _texture_absolute_path


## Returns the texture's absolute path unchanged
## if the project's absolute path is empty.
func _relative_path() -> String:
	return FileUtils.path_made_relative(
			_project_absolute_path.value, _texture_absolute_path
	)
