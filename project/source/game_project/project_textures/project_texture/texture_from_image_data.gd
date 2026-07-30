class_name TextureFromImageData
extends TextureFromId

var _image_data: PackedByteArray


## Given array is never edited, so no need to create a duplicate.
func _init(
		image_data: PackedByteArray, project_textures: ProjectTextures
) -> void:
	_image_data = image_data

	_project_textures = project_textures
	_id = _project_textures.new_id_from_image_data(_image_data)


## Loads the texture using given image data and returns it.
## Returns null if loading fails.
static func from_image_data(image_data: PackedByteArray) -> Texture2D:
	var image := Image.new()
	if image.load_webp_from_buffer(image_data) != OK:
		return null
	return ImageTexture.create_from_image(image)


static func to_image_data(texture_2d: Texture2D) -> PackedByteArray:
	return texture_2d.get_image().save_webp_to_buffer()
