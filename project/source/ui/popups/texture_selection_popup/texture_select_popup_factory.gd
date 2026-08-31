extends Node
## Creates a [TextureSelectPopup] when the user wants to select a texture.

signal popup_created(contents: Node)

const _POPUP_CONTENTS_SCENE: PackedScene = preload("uid://cffc06lk8bb0f")


func create_popup(
		item_texture: ItemTexture, project_textures: ProjectTextures
) -> void:
	var popup := _POPUP_CONTENTS_SCENE.instantiate() as TextureSelectPopup
	popup.texture_selected.connect(item_texture.set_value)
	popup.project_textures = project_textures
	popup_created.emit(popup)
