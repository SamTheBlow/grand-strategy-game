@tool
class_name ItemFloatNode
extends PropertyTreeNode
## A [PropertyTreeNode] that displays an [ItemFloat].

@export var item: ItemFloat

@onready var _label := %Label as Label
@onready var _spin_box := %SpinBox as SpinBox


func _ready() -> void:
	if item == null:
		if not Engine.is_editor_hint():
			push_error("Item is null.")
		return

	refresh()
	_spin_box.value_changed.connect(_on_spin_box_value_changed)
	item.value_changed.connect(_on_item_value_changed)


func refresh() -> void:
	if not is_node_ready() or _item() == null:
		return
	super()

	if item.is_percentage:
		_spin_box.value = item.value * 100.0
		_spin_box.min_value = item.minimum * 100.0
		_spin_box.max_value = item.maximum * 100.0
	else:
		_spin_box.value = item.value
		_spin_box.min_value = item.minimum
		_spin_box.max_value = item.maximum

	_label.text = item.text
	_spin_box.allow_lesser = not item.has_minimum
	_spin_box.allow_greater = not item.has_maximum


func _item() -> PropertyTreeItem:
	return item


func _on_spin_box_value_changed(value: float) -> void:
	if item.is_percentage:
		item.value = value * 0.01
	else:
		item.value = value


func _on_item_value_changed(_input_item: PropertyTreeItem) -> void:
	if item.is_percentage:
		_spin_box.set_value_no_signal(item.value * 100.0)
	else:
		_spin_box.set_value_no_signal(item.value)
