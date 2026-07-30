class_name TextureFromId
extends ProjectTexture

var _id: int = -1
var _project_textures: ProjectTextures


func _init(id: int, project_textures: ProjectTextures) -> void:
	_id = id
	_project_textures = project_textures


func texture(fallback_texture: Texture2D = null) -> Texture2D:
	var output: Texture2D = _project_textures.texture_from_id(_id)
	return output if output != null else fallback_texture


func to_raw_data() -> Variant:
	return _id
