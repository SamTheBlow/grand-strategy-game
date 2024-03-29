extends OptionButton
## Class responsible for opening the different menus for each option.


## Make sure to put them in the same order as the OptionButton options!
@export var options: Array[Control]


func _ready() -> void:
	item_selected.connect(_on_item_selected)
	
	_on_item_selected(selected)
	visibility_changed.connect(_on_visibility_changed)


func _on_item_selected(index: int) -> void:
	for i in options.size():
		options[i].visible = i == index


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_on_item_selected(selected)
	else:
		for option in options:
			option.hide()
