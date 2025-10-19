class_name InterfaceProvinceList
extends AppEditorInterface
## Shows a list of all provinces for the user to edit.

## Emitted when the user selects an item in the list.
signal item_selected(province: Province)

const _PROVINCE_ELEMENT := preload("uid://dpv2or6jsyiwe") as PackedScene

var provinces := Provinces.new():
	set(value):
		provinces = value
		_refresh_list()

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _item_container := %ItemContainer as Node


func _ready() -> void:
	_editor_settings_node.hide()
	super()
	_refresh_list()


func _refresh_list() -> void:
	if not is_node_ready():
		return
	NodeUtils.remove_all_children(_item_container)
	for province in provinces.list():
		_add_element(province)


func _add_element(province: Province) -> void:
	var new_element := _PROVINCE_ELEMENT.instantiate() as ProvinceListElement
	new_element.province = province
	new_element.pressed.connect(_on_element_pressed)
	_item_container.add_child(new_element)


func _on_add_button_pressed() -> void:
	var new_item := Province.new()
	provinces.add(new_item)
	_add_element(new_item)


func _on_element_pressed(element: ProvinceListElement) -> void:
	item_selected.emit(element.province)
