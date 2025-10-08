class_name ProjectTextures
## Encapsulated list of [ProjectTexture]s.

## Maps each unique id to its associated [ProjectTexture] for quick access.
var _id_map: Dictionary[int, ProjectTexture] = { -1: ProjectTexture.new() }
## Maps each file path to its first associated [ProjectTexture].
var _file_map: Dictionary[String, ProjectTexture] = { "": _id_map[-1] }

var _unique_id_system := UniqueIdSystem.new()


## Adds given [ProjectTexture] to the list.
## No effect if its id can't be used.
func add(project_texture: ProjectTexture) -> void:
	if not _unique_id_system.is_id_available(project_texture.id):
		return

	_unique_id_system.claim_id(project_texture.id)
	_id_map[project_texture.id] = project_texture
	if not _file_map.has(project_texture._file_path):
		_file_map[project_texture._file_path] = project_texture


## Returns null if there is no texture with given id.
func texture_from_id(id: int) -> ProjectTexture:
	if _id_map.has(id):
		return _id_map[id]
	return null


## Returns the first [ProjectTexture] associated with given file path.
## Returns null if there are none.
##
## Useful to avoid loading a texture more than once.
func texture_from_file_path(file_path: String) -> ProjectTexture:
	if _file_map.has(file_path):
		return _file_map[file_path]
	return null
