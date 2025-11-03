class_name TextureFromId
extends ProjectTexture

var _id: int = -1


func _init(id: int) -> void:
	_id = id


func texture(
		textures: ProjectTextures, fallback_texture: Texture2D = null
) -> Texture2D:
	if _id < 0:
		return fallback_texture

	var output: Texture2D = textures.texture_from_id(_id)
	return output if output != null else fallback_texture


func to_raw_data() -> Variant:
	return _id
