class_name InterfaceDecorationList
extends AppEditorInterface
## Shows a list of all the world decorations for the user to edit.

signal item_selected(decoration: WorldDecoration)

const _ELEMENT_SCENE := preload("uid://gwjmb35fowhg") as PackedScene

var decorations: WorldDecorations
var project_textures: ProjectTextures

## Maps decorations to their corresponding node for quick access.
var _nodes: Dictionary[WorldDecoration, WorldDecorationListElement] = {}

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _element_container := %ElementContainer as Node


func _ready() -> void:
	_editor_settings_node.item.child_items = [editor_settings.show_decorations]
	_editor_settings_node.refresh()

	for decoration in decorations.list():
		_add_element(decoration)

	decorations.added.connect(_add_element)
	decorations.removed.connect(_remove_element)


func _add_element(world_decoration: WorldDecoration) -> void:
	if _nodes.has(world_decoration):
		push_warning("Decoration already has a corresponding node.")
		return

	var element := _ELEMENT_SCENE.instantiate() as WorldDecorationListElement
	element.world_decoration = world_decoration
	element.project_textures = project_textures

	element.pressed.connect(_on_element_pressed)
	_element_container.add_child(element)
	_nodes[world_decoration] = element


func _remove_element(world_decoration: WorldDecoration) -> void:
	if not _nodes.has(world_decoration):
		push_warning("Decoration doesn't have a corresponding node.")
		return

	_nodes[world_decoration].pressed.disconnect(_on_element_pressed)
	_element_container.remove_child(_nodes[world_decoration])
	_nodes.erase(world_decoration)


func _on_add_button_pressed() -> void:
	var new_item := WorldDecoration.new()
	undo_redo.create_action("Create new world decoration")
	undo_redo.add_do_method(decorations.add.bind(new_item))
	undo_redo.add_undo_method(decorations.remove.bind(new_item))
	undo_redo.commit_action()


func _on_element_pressed(element: WorldDecorationListElement) -> void:
	item_selected.emit(element.world_decoration)
