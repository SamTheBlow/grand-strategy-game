class_name InterfaceDecorationList
extends AppEditorInterface
## Shows a list of all the world decorations for the user to edit.

## Emitted when the user selects an item in the list.
signal item_selected(decoration: WorldDecoration)

const _DECORATION_ELEMENT := preload("uid://gwjmb35fowhg") as PackedScene

var decorations: WorldDecorations:
	set(value):
		if decorations != null:
			decorations.added.disconnect(_add_element)
			decorations.removed.disconnect(_remove_element)

		decorations = value

		_refresh_list()
		decorations.added.connect(_add_element)
		decorations.removed.connect(_remove_element)

var project_textures: ProjectTextures

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _item_container := %ItemContainer as Node


func _ready() -> void:
	# This is just so that this node still works by itself in the Godot editor
	if decorations == null:
		decorations = WorldDecorations.new()

	super()
	_refresh_list()


func _update_editor_settings() -> void:
	if not is_node_ready():
		return
	_editor_settings_node.item.child_items = [editor_settings.show_decorations]
	_editor_settings_node.refresh()


## Deletes existing child nodes and creates new child nodes.
func _refresh_list(_world_decoration: WorldDecoration = null) -> void:
	if not is_node_ready():
		return
	NodeUtils.remove_all_children(_item_container)
	for decoration in decorations.list():
		_add_element(decoration)


## Appends a new child node for given [WorldDecoration].
func _add_element(world_decoration: WorldDecoration) -> void:
	var new_element := (
			_DECORATION_ELEMENT.instantiate() as WorldDecorationListElement
	)
	new_element.world_decoration = world_decoration
	new_element.project_textures = project_textures
	new_element.pressed.connect(_on_element_pressed)
	_item_container.add_child(new_element)


## Removes the first child node that uses given [WorldDecoration].
func _remove_element(world_decoration: WorldDecoration) -> void:
	for child in _item_container.get_children():
		if child is not WorldDecorationListElement:
			continue
		var element := child as WorldDecorationListElement
		if element.world_decoration == world_decoration:
			_item_container.remove_child(element)
			return

	push_warning("Could not find child node with matching world decoration.")


func _on_add_button_pressed() -> void:
	var new_item := WorldDecoration.new()
	undo_redo.create_action("Add new world decoration")
	undo_redo.add_do_method(decorations.add.bind(new_item))
	undo_redo.add_undo_method(decorations.remove.bind(new_item))
	undo_redo.commit_action()


func _on_element_pressed(element: WorldDecorationListElement) -> void:
	item_selected.emit(element.world_decoration)
