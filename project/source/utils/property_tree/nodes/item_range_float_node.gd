@tool
class_name ItemRangeFloatNode
extends PropertyTreeNode
## A [PropertyTreeNode] that displays an [ItemRangeFloat].
## Note that the item's text property is not used.

@export var item: ItemRangeFloat

@onready var _from_spin_box := %FromSpinBox as SpinBox
@onready var _to_spin_box := %ToSpinBox as SpinBox


func _ready() -> void:
	if item == null:
		if not Engine.is_editor_hint():
			push_error("Item is null.")
		return

	refresh()
	_from_spin_box.value_changed.connect(_on_from_spin_box_value_changed)
	_to_spin_box.value_changed.connect(_on_to_spin_box_value_changed)
	item.value_changed.connect(_on_item_value_changed)


func refresh() -> void:
	if not is_node_ready() or _item() == null:
		return
	super()

	_from_spin_box.value = item.min_value
	_from_spin_box.min_value = item.minimum
	_from_spin_box.allow_lesser = not item.has_minimum
	_from_spin_box.max_value = item.maximum
	_from_spin_box.allow_greater = not item.has_maximum

	_to_spin_box.value = item.max_value
	_to_spin_box.min_value = item.minimum
	_to_spin_box.allow_lesser = not item.has_minimum
	_to_spin_box.max_value = item.maximum
	_to_spin_box.allow_greater = not item.has_maximum


func _item() -> PropertyTreeItem:
	return item


func _on_from_spin_box_value_changed(value: float) -> void:
	item.min_value = value


func _on_to_spin_box_value_changed(value: float) -> void:
	item.max_value = value


func _on_item_value_changed(_input_item: PropertyTreeItem) -> void:
	_from_spin_box.set_value_no_signal(item.min_value)
	_to_spin_box.set_value_no_signal(item.max_value)
