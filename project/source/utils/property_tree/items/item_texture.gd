@tool
class_name ItemTexture
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a [ProjectTexture].

signal value_changed(new_value: ProjectTexture)
signal popup_requested(this: ItemTexture)

var value: ProjectTexture = ProjectTexture.none():
	set = set_value

## May be null.
var fallback_texture: Texture2D = null


func set_value(new_value: ProjectTexture) -> void:
	if _is_locked:
		push_warning(_LOCKED_ITEM_MESSAGE)
		return

	if value != new_value:
		value = new_value
		value_changed.emit(value)


func request_popup() -> void:
	popup_requested.emit(self)


func texture() -> Texture2D:
	return value.texture(fallback_texture)
