@tool
class_name ItemTexture
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a [ProjectTexture].

signal value_changed(this: PropertyTreeItem)

var value: ProjectTexture = ProjectTexture.none():
	set(new_value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		if value != new_value:
			value = new_value
			value_changed.emit(self)

## May be null.
var project_textures: ProjectTextures
## May be null.
var fallback_texture: Texture2D


func texture() -> Texture2D:
	if project_textures == null:
		return null
	return value.texture(project_textures, fallback_texture)
