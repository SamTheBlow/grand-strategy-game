@tool
class_name ItemVoidNode
extends PropertyTreeNode
## A [PropertyTreeNode] that displays an item with no data of its own.

@export var item: PropertyTreeItem

@onready var _label := %Label as Label
@onready var _item_container := %ItemContainer as HBoxContainer


func _ready() -> void:
	if item == null:
		if not Engine.is_editor_hint():
			push_error("Item is null.")
		return

	refresh()


func refresh() -> void:
	if not is_node_ready() or _item() == null:
		return
	super()

	_label.text = item.text
	_item_container.visible = not item.text.is_empty()


func _item() -> PropertyTreeItem:
	return item
