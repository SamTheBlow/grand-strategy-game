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
