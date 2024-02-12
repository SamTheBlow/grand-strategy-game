extends OptionButton
## Class responsible for opening the different menus for each option.


## Make sure to put them in the same order as the OptionButton options!
@export var options: Array[Control]


func _ready() -> void:
	item_selected.connect(_on_item_selected)
	
	_on_item_selected(selected)


func _on_item_selected(index: int) -> void:
	for i in options.size():
		if i == index:
			options[i].show()
		else:
			options[i].hide()
