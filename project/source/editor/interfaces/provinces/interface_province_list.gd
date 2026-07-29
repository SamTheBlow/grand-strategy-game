class_name InterfaceProvinceList
extends AppEditorInterface
## Shows a list of all provinces for the user to edit.

signal item_selected(province_id: int)

const _ELEMENT_SCENE := preload("uid://dpv2or6jsyiwe") as PackedScene

var provinces: Provinces

## Maps province ids to their corresponding node.
var _nodes: Dictionary[int, Node] = {}

@onready var _element_container := %ElementContainer as Node


func _ready() -> void:
	for province in provinces.list():
		_add_element(province)

	provinces.added.connect(_on_province_added)
	provinces.removed.connect(_on_province_removed)


func _add_element(province: Province) -> void:
	if _nodes.has(province.id):
		push_warning("Province already has a corresponding node.")
		return

	var element := _ELEMENT_SCENE.instantiate() as ProvinceListElement
	element.province = province
	element.pressed.connect(_on_element_pressed)
	_element_container.add_child(element)
	_nodes[province.id] = element


func _on_add_button_pressed() -> void:
	var new_province := Province.new()

	# We need this new province to have a new unique id
	# assigned to it before we can create the undo_redo action
	provinces.add(new_province)

	# Create undo_redo action
	# (don't execute it since we already added the province)
	undo_redo.create_action("Create new province")
	undo_redo.add_do_method(provinces.add.bind(new_province))
	undo_redo.add_undo_method(provinces.remove.bind(new_province.id))
	undo_redo.commit_action(false)


func _on_element_pressed(element: ProvinceListElement) -> void:
	item_selected.emit(element.province.id)


func _on_province_added(province: Province) -> void:
	_add_element(province)
	var position_index: int = provinces.position_of(province.id)
	_element_container.move_child(_nodes[province.id], position_index)


func _on_province_removed(province: Province) -> void:
	if not _nodes.has(province.id):
		push_warning("Province doesn't have a corresponding node.")
		return

	_element_container.remove_child(_nodes[province.id])
	_nodes.erase(province.id)
