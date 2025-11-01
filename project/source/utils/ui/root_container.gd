class_name RootContainer
extends HBoxContainer
## Shows or hides given nodes when a given [CheckBox] is checked or unchecked.

@export var nodes_to_hide: Array[Control]
@export var trigger_check_box: CheckBox


func _ready() -> void:
	trigger_check_box.toggled.connect(_on_check_box_toggled)
	_on_check_box_toggled()


func _on_check_box_toggled(_toggled_on: bool = false) -> void:
	for node in nodes_to_hide:
		node.visible = trigger_check_box.button_pressed
