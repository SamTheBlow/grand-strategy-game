class_name CustomOptionButton
extends OptionButton
## When you select an item from this button's options, it shows the
## Control node associated with that item, and hides all the other ones.
## Also, when this node is hidden, all of the option nodes are also hidden.


## Make sure to put the nodes in the same order as the OptionButton options!
@export var options: Array[Control]


func _ready() -> void:
	item_selected.connect(_on_item_selected)
	
	_on_item_selected(selected)
	visibility_changed.connect(_on_visibility_changed)


## This is useful because setting the selected item
## through code doesn't emit the item_selected signal.
func select_item(item: int) -> void:
	select(item)
	item_selected.emit(item)


func _on_item_selected(index: int) -> void:
	for i in options.size():
		options[i].visible = i == index


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_on_item_selected(selected)
	else:
		for option in options:
			option.hide()
