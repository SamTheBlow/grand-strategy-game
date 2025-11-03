class_name ProjectTextures
## Stores all of a project's textures in one place.
## Allows for referencing a texture using a unique id number.
## Prevents loading the same texture more than once.

## Maps each unique id to its associated texture.
var _id_map: Dictionary[int, Texture2D] = {}
## Maps each absolute file path to its associated texture id.
var _file_map: Dictionary[String, int] = {}

var _project_absolute_path: StringRef
var _unique_id_system := UniqueIdSystem.new()


func _init(project_absolute_path: StringRef) -> void:
	_project_absolute_path = project_absolute_path


## This id's texture will be null.
## No effect if given id cannot be claimed.
func claim_id(id: int) -> void:
	if _unique_id_system.is_id_available(id):
		_unique_id_system.claim_id(id)
		_id_map[id] = null


## Loads texture at given file path and assigns it given id,
## even if given file path is already in use.
func claim_id_with_file_path(id: int, absolute_file_path: String) -> void:
	if not _unique_id_system.is_id_available(id):
		return
	_unique_id_system.claim_id(id)
	_id_map[id] = _texture_from_path(absolute_file_path)
	_file_map[absolute_file_path] = id


## Loads texture using given image data and assigns it given id.
func claim_id_with_image_data(id: int, image_data: PackedByteArray) -> void:
	if not _unique_id_system.is_id_available(id):
		return
	_unique_id_system.claim_id(id)
	_id_map[id] = _texture_from_image_data(image_data)


## Loads the texture at given file path and assigns it a new unique id.
## Returns the new texture's id.
## Or, if texture at given file path was already loaded,
## avoids loading the texture again and returns that texture's id instad.
func new_id_from_file_path(absolute_file_path: String) -> int:
	if _file_map.has(absolute_file_path):
		return _file_map[absolute_file_path]

	var id: int = _unique_id_system.new_unique_id()
	_id_map[id] = _texture_from_path(absolute_file_path)
	_file_map[absolute_file_path] = id
	return id


## Loads the texture using given image data and assigns it a new unique id.
## Returns the new texture's id.
func new_id_from_image_data(image_data: PackedByteArray) -> int:
	var id: int = _unique_id_system.new_unique_id()
	_id_map[id] = _texture_from_image_data(image_data)
	return id


## Returns null if there is no texture with given id.
## May also return null if texture with given id failed to load.
func texture_from_id(id: int) -> Texture2D:
	if _id_map.has(id):
		return _id_map[id]

	push_warning("There doesn't exist a texture with id: ", id)
	return null


## Returns a reference to the project's absolute path.
func project_absolute_path_ref() -> StringRef:
	return _project_absolute_path


## Loads a texture from given file path.
## The texture's file path must be relative to given project path
## (unless the project path is empty).
## Returns null if an error occurs.
static func texture_from_relative_path(
		project_absolute_path: String, texture_path: String
) -> Texture2D:
	return _texture_from_path(
			texture_path_made_absolute(project_absolute_path, texture_path)
	)


static func texture_path_made_absolute(
		project_absolute_path: String, texture_path: String
) -> String:
	if project_absolute_path == "":
		return texture_path

	if texture_path.is_absolute_path():
		push_warning(
				"Texture has an absolute file path.",
				" It will be loaded anyway, but please do not use",
				" absolute paths in your save files. (",
				texture_path, ")"
		)
		return texture_path


	var project_dir: DirAccess = (
			DirAccess.open(project_absolute_path.get_base_dir())
	)

	if project_dir == null:
		push_warning(
				"Failed to open project's base directory. (", project_dir, ")"
		)
		return ""

	if project_dir.change_dir(texture_path.get_base_dir()) != OK:
		push_warning(
				"Failed to open texture's base directory. (",
				texture_path, ")"
		)
		return ""

	return project_dir.get_current_dir().path_join(texture_path.get_file())


static func _texture_from_path(path: String) -> Texture2D:
	# If the image was already imported into the engine, we can use load().
	if ResourceLoader.exists(path, "Texture2D"):
		return load(path) as Texture2D

	# If the image is inside the "res://" folder, then Image.load_from_file()
	# won't work after exporting. We can't load the image.
	if path.begins_with("res://"):
		push_warning("Texture is inside resource folder but was not imported.")
		return null

	if not FileAccess.file_exists(path):
		push_warning("File doesn't exist: ", path)
		return null

	var image := Image.new()
	if image.load(path) != OK:
		push_warning("File is not a valid image.")
		return null

	return ImageTexture.create_from_image(image)


static func _texture_from_image_data(image_data: PackedByteArray) -> Texture2D:
	return TextureFromImageData.from_image_data(image_data)
