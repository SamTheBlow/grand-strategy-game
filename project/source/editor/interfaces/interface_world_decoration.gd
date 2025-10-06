class_name InterfaceWorldDecoration
extends AppEditorInterface
## Shows a list of all the world decorations.

## Emitted when the user selects a [WorldDecoration] in the list.
signal decoration_selected(decoration: WorldDecoration)

const _DECORATION_ELEMENT := preload("uid://gwjmb35fowhg") as PackedScene

var decorations := WorldDecorations.new():
	set(value):
		decorations = value
		_refresh_list()

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _decoration_container := %DecoContainer as Node


func _ready() -> void:
	super()
	_refresh_list()


func _update_editor_settings() -> void:
	if not is_node_ready():
		return
	_editor_settings_node.item.child_items = [
		editor_settings.show_decorations
	]
	_editor_settings_node.refresh()


func _refresh_list() -> void:
	if decorations == null or not is_node_ready():
		return
	NodeUtils.remove_all_children(_decoration_container)
	for decoration in decorations.list():
		_add_element(decoration)


func _add_element(decoration: WorldDecoration) -> void:
	var new_element := (
			_DECORATION_ELEMENT.instantiate() as WorldDecorationListElement
	)
	new_element.world_decoration = decoration
	new_element.pressed.connect(_on_element_pressed)
	_decoration_container.add_child(new_element)


func _on_add_button_pressed() -> void:
	var new_decoration := WorldDecoration.new()
	decorations.add(new_decoration)
	_add_element(new_decoration)


func _on_element_pressed(element: WorldDecorationListElement) -> void:
	decoration_selected.emit(element.world_decoration)
