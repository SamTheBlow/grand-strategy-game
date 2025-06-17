@tool
class_name ItemVector2Node
extends PropertyTreeNode
## A [PropertyTreeNode] that displays an [ItemVector2].

@export var item: ItemVector2

@onready var _label := %Label as Label
@onready var _spin_box_1 := %Value1 as SpinBox
@onready var _spin_box_2 := %Value2 as SpinBox


func _ready() -> void:
	if item == null:
		if not Engine.is_editor_hint():
			push_error("Item is null.")
		return

	refresh()
	_spin_box_1.value_changed.connect(_on_spin_box_1_value_changed)
	_spin_box_2.value_changed.connect(_on_spin_box_2_value_changed)
	item.value_changed.connect(_on_item_value_changed)


func refresh() -> void:
	if not is_node_ready() or _item() == null:
		return
	super()

	_spin_box_1.value = item.value_x
	_spin_box_1.suffix = item.suffix
	_spin_box_2.value = item.value_y
	_spin_box_2.suffix = item.suffix

	_label.text = item.text


func _item() -> PropertyTreeItem:
	return item


func _on_spin_box_1_value_changed(value: float) -> void:
	item.value_x = value


func _on_spin_box_2_value_changed(value: float) -> void:
	item.value_y = value


func _on_item_value_changed(_input_item: PropertyTreeItem) -> void:
	_spin_box_1.set_value_no_signal(item.value_x)
	_spin_box_2.set_value_no_signal(item.value_y)
