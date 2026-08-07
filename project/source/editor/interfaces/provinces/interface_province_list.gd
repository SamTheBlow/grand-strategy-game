class_name InterfaceProvinceList
extends AppEditorInterface
## Shows a list of all provinces for the user to edit.

const _ELEMENT_SCENE := preload("uid://dpv2or6jsyiwe") as PackedScene

## Maps province ids to their corresponding node.
var _nodes: Dictionary[int, Node] = {}

@onready var _element_container := %ElementContainer as Node


func _ready() -> void:
	for province in project.game.world.provinces.list():
		_add_element(province)

	project.game.world.provinces.added.connect(_on_province_added)
	project.game.world.provinces.removed.connect(_on_province_removed)

	closed.connect(navigator.close_interface)
	tree_exited.connect(province_list_item_unhovered.emit)


func _add_element(province: Province) -> void:
	var element := _ELEMENT_SCENE.instantiate() as ProvinceListElement
	element.province = province
	element.pressed.connect(_on_element_pressed)
	element.mouse_entered.connect(
			province_list_item_hovered.emit.bind(province)
	)
	element.mouse_exited.connect(province_list_item_unhovered.emit)
	_element_container.add_child(element)
	_nodes[province.id] = element


func _on_add_button_pressed() -> void:
	var new_province := Province.new()

	# We need this new province to have a new unique id
	# assigned to it before we can create the undo_redo action
	project.game.world.provinces.add(new_province)

	# Create undo_redo action
	# (don't execute it since we already added the province)
	undo_redo.create_action("Create new province")
	undo_redo.add_do_method(
			project.game.world.provinces.add.bind(new_province)
	)
	undo_redo.add_undo_method(
			project.game.world.provinces.remove.bind(new_province.id)
	)
	undo_redo.commit_action(false)


func _on_element_pressed(element: ProvinceListElement) -> void:
	province_select_requested.emit(element.province)


func _on_province_added(province: Province) -> void:
	_add_element(province)
	_element_container.move_child(
			_nodes[province.id],
			project.game.world.provinces.position_of(province.id)
	)


func _on_province_removed(province: Province) -> void:
	_element_container.remove_child(_nodes[province.id])
	_nodes.erase(province.id)
