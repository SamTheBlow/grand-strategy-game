class_name ProjectTexture

## The default texture is an empty 1px image.
static var _default_texture: Texture2D = ImageTexture.create_from_image(
		Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
)

var id: int = -1
var texture: Texture2D = _default_texture
var _file_path: String = ""


## Loads the texture using given file path.
## No effect if loading fails.
## Returns an error message (empty string if no error).
func load_texture_from_path(file_path: String) -> String:
	if file_path == "":
		return "No file path provided."

	var image: Image = null
	if file_path.begins_with("res://"):
		image = load(file_path) as Image
	else:
		image = Image.load_from_file(file_path)
	if image == null:
		return "Failed to load image from file path."

	# Success
	texture = ImageTexture.create_from_image(image)
	_file_path = file_path
	return ""


## Loads the texture using given raw image data.
## No effect if loading fails.
## Returns an error message (empty string if no error).
func load_texture_from_data(raw_image_data: PackedByteArray) -> String:
	var image := Image.new()
	var error: Error = image.load_webp_from_buffer(raw_image_data)
	if error != OK:
		return "Failed to load image from raw data."

	# Success
	texture = ImageTexture.create_from_image(image)
	_file_path = ""
	return ""


## Returns the texture as raw image data.
func texture_data() -> PackedByteArray:
	return texture.get_image().save_webp_to_buffer()


## Loads a texture from given file path.
## The texture's file path must be relative to given project path.
## Returns null if an error occurs.
static func texture_from_relative_path(
		project_absolute_path: String, texture_relative_path: String
) -> Texture2D:
	if project_absolute_path == "" or texture_relative_path == "":
		return null

	if texture_relative_path.is_absolute_path():
		push_warning("Texture has an absolute file path.")
		return null

	var project_dir: DirAccess = (
			DirAccess.open(project_absolute_path.get_base_dir())
	)
	if project_dir == null:
		return null
	if project_dir.change_dir(texture_relative_path.get_base_dir()) != OK:
		return null
	var texture_absolute_path: String = (
			project_dir.get_current_dir()
			.path_join(texture_relative_path.get_file())
	)

	# If the image was already imported into the engine, we can use load().
	if ResourceLoader.exists(texture_absolute_path, "Texture2D"):
		return load(texture_absolute_path) as Texture2D

	# If the image is inside the "res://" folder, then Image.load_from_file()
	# won't work after exporting. We can't load the image.
	if texture_absolute_path.begins_with("res://"):
		push_warning("Texture is inside resource folder but was not imported.")
		return null

	if not FileAccess.file_exists(texture_absolute_path):
		push_warning("File doesn't exist: ", texture_absolute_path)
		return null

	return ImageTexture.create_from_image(
			Image.load_from_file(texture_absolute_path)
	)
