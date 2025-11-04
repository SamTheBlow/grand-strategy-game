class_name TextureInternal
extends ProjectTexture
## A texture retrieved from the app's internal resources.

var _keyword: String
var _texture: Texture2D


func _init(keyword: String) -> void:
	_keyword = keyword
	_texture = preload("uid://doda8npdqckhw").texture_with_keyword(_keyword)


func texture(
		_textures: ProjectTextures, fallback_texture: Texture2D = null
) -> Texture2D:
	return _texture if _texture != null else fallback_texture


func to_raw_data() -> Variant:
	return _keyword
