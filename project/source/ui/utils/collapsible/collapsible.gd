class_name Collapsible
extends VBoxContainer
## Shows a button with given text. When you click on the button,
## its contents expand. When you click on it again, the contents collapse.

@export var title: String = "Title":
	set(value):
		title = value
		_update_title()

@onready var _button := %Button as Button
@onready var _collapsible_container := (
		%CollapsibleContainer as CollapsibleContainer
)
@onready var _contents := %Contents as VBoxContainer


func _ready() -> void:
	_update_title()


## Removes all the nodes that were added to the contents.
func clear() -> void:
	NodeUtils.remove_all_children(_contents)


## Adds given [Control] to the contents, at the bottom.
func add_node(control: Control) -> void:
	_contents.add_child(control)


## Manually expand the contents. No effect if contents are already expanded.
func expand() -> void:
	_collapsible_container.open_tween()


func _update_title() -> void:
	if not is_node_ready():
		return
	
	_button.text = title
