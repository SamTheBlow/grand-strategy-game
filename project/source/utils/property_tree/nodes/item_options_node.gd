@tool
class_name ItemOptionsNode
extends PropertyTreeNode
## A [PropertyTreeNode] that displays an [ItemOptions].

@export var item: ItemOptions

@onready var _label := %Label as Label
@onready var _option_button := %CustomOptionButton as CustomOptionButton


func _ready() -> void:
	if item == null:
		if not Engine.is_editor_hint():
			push_error("Item is null.")
		return

	refresh()
	_option_button.item_selected.connect(_on_option_selected)
	item.value_changed.connect(_on_item_value_changed)


func refresh() -> void:
	if not is_node_ready() or _item() == null:
		return
	super()

	_label.text = item.text

	_option_button.clear()
	for option_name in item.options:
		_option_button.add_item(option_name)

	_setup_filters()
	_option_button.select_item(item.selected_index)


func _item() -> PropertyTreeItem:
	return item


func _setup_filters() -> void:
	for option_filter in item.option_filters:
		var node_option_filter: Array[Control] = []
		for index in option_filter:
			node_option_filter.append(_child_item_nodes[index])
		_option_button.option_filters.append(node_option_filter)


func _on_option_selected(selected: int) -> void:
	item.selected_index = selected


func _on_item_value_changed(_input_item: PropertyTreeItem) -> void:
	_option_button.select_item(item.selected_index)
