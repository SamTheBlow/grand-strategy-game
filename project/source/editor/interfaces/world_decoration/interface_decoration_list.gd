class_name InterfaceDecorationList
extends AppEditorInterface
## Shows a list of all the world decorations for the user to edit.

const _ELEMENT_SCENE := preload("uid://gwjmb35fowhg") as PackedScene

## Maps decorations to their corresponding node for quick access.
var _nodes: Dictionary[WorldDecoration, WorldDecorationListElement] = {}

@onready var _element_container := %ElementContainer as Node


func _ready() -> void:
	var editor_settings_node := %EditorSettingsCategory as ItemVoidNode
	editor_settings_node.item.child_items = [
		editor_settings.show_decorations
	]
	editor_settings_node.refresh()

	for decoration in project.game.world.decorations.list():
		_add_element(decoration)

	project.game.world.decorations.added.connect(_add_element)
	project.game.world.decorations.removed.connect(_remove_element)

	closed.connect(navigator.close_interface)
	tree_exited.connect(decoration_list_item_unhovered.emit)


func _add_element(world_decoration: WorldDecoration) -> void:
	var element := _ELEMENT_SCENE.instantiate() as WorldDecorationListElement
	element.world_decoration = world_decoration
	element.pressed.connect(_on_element_pressed)
	element.mouse_entered.connect(decoration_list_item_hovered.emit.bind(world_decoration))
	element.mouse_exited.connect(decoration_list_item_unhovered.emit)
	_element_container.add_child(element)
	_nodes[world_decoration] = element


func _remove_element(world_decoration: WorldDecoration) -> void:
	_nodes[world_decoration].pressed.disconnect(_on_element_pressed)
	_element_container.remove_child(_nodes[world_decoration])
	_nodes.erase(world_decoration)


func _on_add_button_pressed() -> void:
	var new_item := WorldDecoration.new()
	undo_redo.create_action("Create new world decoration")
	undo_redo.add_do_method(
			project.game.world.decorations.add.bind(new_item)
	)
	undo_redo.add_undo_method(
			project.game.world.decorations.remove.bind(new_item)
	)
	undo_redo.commit_action()


func _on_element_pressed(element: WorldDecorationListElement) -> void:
	navigator.open_decoration_edit_interface(
			element.world_decoration, project, editor_settings
	)
