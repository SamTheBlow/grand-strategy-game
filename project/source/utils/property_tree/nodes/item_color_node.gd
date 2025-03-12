@tool
class_name ItemColorNode
extends PropertyTreeNode
## A [PropertyTreeNode] that displays an [ItemColor].

@export var item: ItemColor

@onready var _label := %Label as Label
@onready var _color_picker := %ColorPickerButton as ColorPickerButton


func _ready() -> void:
	if item == null:
		if not Engine.is_editor_hint():
			push_error("Item is null.")
		return

	refresh()
	_color_picker.color_changed.connect(_on_color_picker_color_changed)
	item.value_changed.connect(_on_item_value_changed)
	item.transparency_toggled.connect(_on_transparency_toggled)


func refresh() -> void:
	if not is_node_ready() or _item() == null:
		return
	super()

	_label.text = item.text
	_color_picker.edit_alpha = item.is_transparency_enabled
	_color_picker.color = item.value


func _item() -> PropertyTreeItem:
	return item


func _on_color_picker_color_changed(color: Color) -> void:
	item.value = color


func _on_item_value_changed(_input_item: PropertyTreeItem) -> void:
	# Disconnect signal to prevent infinite loop
	_color_picker.color_changed.disconnect(_on_color_picker_color_changed)
	_color_picker.color = item.value
	_color_picker.color_changed.connect(_on_color_picker_color_changed)


func _on_transparency_toggled(_input_item: PropertyTreeItem) -> void:
	_color_picker.edit_alpha = item.is_transparency_enabled
