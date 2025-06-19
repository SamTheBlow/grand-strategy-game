@tool
class_name ItemTexture
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a [Texture2D].

signal value_changed(this: PropertyTreeItem)

## May be null.
@export var value: Texture2D = null:
	set(new_value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		if value != new_value:
			value = new_value
			value_changed.emit(self)


func get_data() -> Dictionary:
	return {} # TODO give raw image data


func set_data(data: Variant) -> void:
	if data is Dictionary:
		# TODO turn raw image data into a texture
		push_error("Not implemented yet...")
	else:
		push_warning(_INVALID_TYPE_MESSAGE)
