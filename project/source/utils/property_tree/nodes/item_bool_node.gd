@tool
class_name ItemBoolNode
extends PropertyTreeNode
## A [PropertyTreeNode] that displays an [ItemBool].

@export var item: ItemBool

var _child_item_nodes_on: Array[CanvasItem] = []
var _child_item_nodes_off: Array[CanvasItem] = []

@onready var _label := %Label as Label
@onready var _check_box := %CheckBox as CheckBox


func _ready() -> void:
	if item == null:
		if not Engine.is_editor_hint():
			push_error("Item is null.")
		return

	refresh()
	_check_box.toggled.connect(_on_check_box_toggled)
	item.value_changed.connect(_on_item_value_changed)


func refresh() -> void:
	if not is_node_ready() or _item() == null:
		return
	super()

	_label.text = item.text
	_check_box.button_pressed = item.value
	_store_child_item_nodes()
	_update_child_item_visibility()


func _item() -> PropertyTreeItem:
	return item


func _store_child_item_nodes() -> void:
	_child_item_nodes_on = []
	_child_item_nodes_off = []
	for i in _child_item_nodes.size():
		if item.child_items_on.has(i):
			_child_item_nodes_on.append(_child_item_nodes[i])
			continue
		if item.child_items_off.has(i):
			_child_item_nodes_off.append(_child_item_nodes[i])


func _update_child_item_visibility() -> void:
	for child_item in _child_item_nodes_on:
		child_item.visible = item.value
	for child_item in _child_item_nodes_off:
		child_item.visible = not item.value


func _on_check_box_toggled(toggled_on: bool) -> void:
	item.value = toggled_on
	_update_child_item_visibility()


func _on_item_value_changed(_input_item: PropertyTreeItem) -> void:
	_check_box.set_pressed_no_signal(item.value)
	_update_child_item_visibility()
