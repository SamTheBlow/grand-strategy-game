class_name TextureFromImageData
extends TextureFromId

var _image_data: PackedByteArray


## Given array is never edited, so no need to create a duplicate.
func _init(image_data: PackedByteArray) -> void:
	_image_data = image_data


func texture(
		textures: ProjectTextures, fallback_texture: Texture2D = null
) -> Texture2D:
	if _id < 0:
		_id = textures.new_id_from_image_data(_image_data)

	return super(textures, fallback_texture)


func to_raw_data() -> Variant:
	if _id < 0:
		return Array(_image_data)

	return super()


## Loads the texture using given image data and returns it.
## Returns null if loading fails.
static func from_image_data(image_data: PackedByteArray) -> Texture2D:
	var image := Image.new()
	if image.load_webp_from_buffer(image_data) != OK:
		return null
	return ImageTexture.create_from_image(image)


static func to_image_data(texture_2d: Texture2D) -> PackedByteArray:
	return texture_2d.get_image().save_webp_to_buffer()
