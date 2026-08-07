class_name InterfaceArmyList
extends AppEditorInterface
## Shows a list of all armies for the user to edit.

const _ELEMENT_SCENE := preload("uid://c06m34xmh3nnl") as PackedScene

## New armies will be placed in this province.
## May be null, in which case creating new armies is disabled.
var _selected_province: Province = null:
	set(value):
		_selected_province = value
		_refresh_add_button()

## Maps army ids to their corresponding node.
var _nodes: Dictionary[int, Node] = {}
## The order in which the armies are sorted.
var _order: Array[Army] = []

@onready var _add_button := %AddButton as Button
@onready var _element_container := %ElementContainer as Node


func _ready() -> void:
	_refresh_add_button()

	for army in project.game.world.armies.list():
		_add_element(army)

	project.game.world.armies.added.connect(_add_element)
	project.game.world.armies.removed.connect(_remove_element)

	closed.connect(navigator.close_interface)
	tree_exited.connect(army_list_item_unhovered.emit)


func _refresh_add_button() -> void:
	_add_button.disabled = (
			_selected_province == null
			or _selected_province.owner_country == null
	)


func _add_element(army: Army) -> void:
	_connect_country(army.owner_country)
	army.allegiance_changed.connect(_connect_country)

	var element := _ELEMENT_SCENE.instantiate() as ArmyListElement
	element.army = army
	element.playing_country = PlayingCountry.new(project.game)
	element.pressed.connect(army_select_requested.emit.bind(army))
	element.mouse_entered.connect(army_list_item_hovered.emit.bind(army))
	element.mouse_exited.connect(army_list_item_unhovered.emit)

	# Determine the position in the list to put this in
	# (they're sorted by country alphabetical order).
	var new_index: int = 0
	for sorted_army in _order:
		if (
				army.owner_country.name_or_default()
				< sorted_army.owner_country.name_or_default()
		):
			break
		new_index += 1

	_element_container.add_child(element)
	_element_container.move_child(element, new_index)
	_nodes[army.id] = element
	_order.insert(new_index, army)


func _remove_element(army: Army) -> void:
	army.allegiance_changed.disconnect(_connect_country)

	_element_container.remove_child(_nodes[army.id])
	_nodes.erase(army.id)
	_order.erase(army)


func _connect_country(country: Country) -> void:
	if not country.name_changed.is_connected(_on_country_name_changed):
		country.name_changed.connect(_on_country_name_changed.bind(country))


func _on_add_button_pressed() -> void:
	if _selected_province == null or _selected_province.owner_country == null:
		return

	var new_army: Army = Army.Factory.new(project.game).new_army(
			_selected_province.owner_country, _selected_province.id
	)

	# Create undo_redo action
	# (don't execute it since factory setup already added the army)
	undo_redo.create_action("Create new army")
	undo_redo.add_do_method(project.game.world.armies.add.bind(new_army))
	undo_redo.add_undo_method(project.game.world.armies.remove.bind(new_army))
	undo_redo.commit_action(false)


func _on_country_name_changed(country: Country) -> void:
	var armies_to_sort: Array[Army] = []
	for sorted_army in _order:
		if sorted_army.owner_country == country:
			armies_to_sort.append(sorted_army)

	for army in armies_to_sort:
		# Remove it and re-add it so that it gets properly sorted
		_remove_element(army)
		_add_element(army)
