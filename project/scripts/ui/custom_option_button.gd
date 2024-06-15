class_name CustomOptionButton
extends OptionButton
## When you select an item from this button's options, it shows the
## Control nodes associated with that item, and hides all the other ones.
## Also, when this node is hidden, all of the option nodes are also hidden.


## Effectively an Array[Array[Control]].
## Associates an array of Control nodes to each OptionButton option.
## Make sure to put the filters in the same order as the OptionButton options!
@export var option_filters: Array


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
	for i in option_filters.size():
		for control: Control in (option_filters[i] as Array):
			control.visible = i == index


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_on_item_selected(selected)
		return
	
	for i in option_filters.size():
		for control: Control in (option_filters[i] as Array):
			control.hide()
