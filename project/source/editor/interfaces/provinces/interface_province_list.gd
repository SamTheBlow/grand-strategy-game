class_name InterfaceProvinceList
extends AppEditorInterface
## Shows a list of all provinces for the user to edit.

## Emitted when the user selects an item in the list.
signal item_selected(province_id: int)

const _PROVINCE_ELEMENT_SCENE := preload("uid://dpv2or6jsyiwe") as PackedScene

var _is_setup: bool = false
var _provinces: Provinces

## Maps province ids to their corresponding node.
var _nodes: Dictionary[int, Node] = {}

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _item_container := %ItemContainer as Node


func _ready() -> void:
	_editor_settings_node.hide()
	super()

	if _is_setup:
		_update()


func setup(provinces: Provinces) -> void:
	if _is_setup and is_node_ready():
		_provinces.added.disconnect(_on_province_added)
		_provinces.removed.disconnect(_on_province_removed)

	_provinces = provinces
	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	NodeUtils.remove_all_children(_item_container)
	_nodes = {}

	for province in _provinces.list():
		_add_element(province)

	_provinces.added.connect(_on_province_added)
	_provinces.removed.connect(_on_province_removed)


func _add_element(province: Province) -> void:
	if _nodes.has(province.id):
		push_warning("Province already has a corresponding node.")
		return

	var new_element := (
			_PROVINCE_ELEMENT_SCENE.instantiate() as ProvinceListElement
	)
	new_element.province = province
	new_element.pressed.connect(_on_element_pressed)
	_item_container.add_child(new_element)
	_nodes[province.id] = new_element


func _on_add_button_pressed() -> void:
	_provinces.add(Province.new())


func _on_element_pressed(element: ProvinceListElement) -> void:
	item_selected.emit(element.province.id)


func _on_province_added(province: Province) -> void:
	_add_element(province)


func _on_province_removed(province: Province) -> void:
	if _nodes.has(province.id):
		NodeUtils.delete_node(_nodes[province.id])
		_nodes.erase(province.id)
	else:
		push_warning("Province doesn't have a corresponding node.")
