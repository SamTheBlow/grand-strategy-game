@tool
class_name ItemStringNode
extends PropertyTreeNode
## A [PropertyTreeNode] that displays an [ItemString].

@export var item: ItemString

@onready var _label := %Label as Label
@onready var _line_edit := %LineEdit as LineEdit


func _ready() -> void:
	if item == null:
		if not Engine.is_editor_hint():
			push_error("Item is null.")
		return

	refresh()
	_line_edit.text_changed.connect(_on_text_changed)
	item.value_changed.connect(_on_item_value_changed)
	item.placeholder_text_changed.connect(_on_placeholder_text_changed)


func refresh() -> void:
	if not is_node_ready():
		return
	super()
	_label.text = item.text
	_line_edit.text = item.value
	_line_edit.placeholder_text = item.placeholder_text


func _item() -> PropertyTreeItem:
	return item


func _on_text_changed(text: String) -> void:
	# Disconnect the signal temporarily to avoid infinite loop
	# and to avoid messing with the LineEdit's cursor
	item.value_changed.disconnect(_on_item_value_changed)
	item.value = text
	item.value_changed.connect(_on_item_value_changed)


func _on_item_value_changed(_input_item: PropertyTreeItem) -> void:
	_line_edit.text = item.value


func _on_placeholder_text_changed(_input_item: PropertyTreeItem) -> void:
	_line_edit.placeholder_text = item.placeholder_text
