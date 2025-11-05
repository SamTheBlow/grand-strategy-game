extends Node

const _GAME_POPUP_SCENE: PackedScene = preload("uid://by865efl4iwy")
const _TEXTURE_SELECT_POPUP_SCENE: PackedScene = preload("uid://cffc06lk8bb0f")

@export var _popup_container: Control


func _open_popup(item_texture: ItemTexture) -> void:
	var popup := _GAME_POPUP_SCENE.instantiate() as GamePopup
	var texture_select_popup := (
			_TEXTURE_SELECT_POPUP_SCENE.instantiate() as TextureSelectPopup
	)
	texture_select_popup.texture_selected.connect(
			_on_texture_selected.bind(item_texture)
	)
	if item_texture.project_textures != null:
		texture_select_popup.project_absolute_path = (
				item_texture.project_textures.project_absolute_path_ref()
		)
	popup.contents_node = texture_select_popup
	_popup_container.add_child(popup)


func _on_texture_selected(texture: ProjectTexture, item: ItemTexture) -> void:
	item.value = texture
