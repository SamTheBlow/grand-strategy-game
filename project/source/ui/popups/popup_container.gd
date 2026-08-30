class_name PopupContainer
extends Control
## Adds a [GamePopup] to the scene tree with some given contents.

const _POPUP_SCENE: PackedScene = preload("uid://by865efl4iwy")


func add_popup(contents: Node) -> void:
	var popup := _POPUP_SCENE.instantiate() as GamePopup
	popup.contents_node = contents
	add_child(popup)
