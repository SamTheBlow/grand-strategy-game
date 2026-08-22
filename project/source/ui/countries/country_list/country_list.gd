class_name CountryListNode
extends Control
## Displays a list of countries as buttons.
## Clicking on a country emits a signal.

signal country_selected(country: Country)

const _ELEMENT_SCENE := preload("uid://bdw77emy4euku") as PackedScene

## Maps elements to their corresponding node.
var _nodes: Dictionary[Country, Node] = {}
## Keeps track of the order the countries are in.
var _sorted_countries: Array[Country] = []

@onready var _element_container := %CountryContainer as Node


func setup(countries: Countries, is_no_country_allowed: bool) -> void:
	if not is_node_ready():
		await ready

	if is_no_country_allowed:
		_add_element(null)
	for country in countries.list():
		_add_element(country)

	if _nodes.is_empty():
		_add_empty_list_label()

	countries.added.connect(_add_element)
	countries.removed.connect(_remove_element)


func _add_empty_list_label() -> void:
	var empty_list_label := Label.new()
	empty_list_label.text = "(There are no countries.)"
	empty_list_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	empty_list_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	empty_list_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_list_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_element_container.add_child(empty_list_label)


func _remove_empty_list_label() -> void:
	NodeUtils.remove_all_children(_element_container)


func _add_element(new_country: Country) -> void:
	if _nodes.has(new_country):
		push_warning("Country already has a corresponding node.")
		return

	if _nodes.is_empty():
		_remove_empty_list_label()

	if new_country != null:
		new_country.name_changed.connect(
				_on_country_name_changed.bind(new_country)
		)

	var new_element := _ELEMENT_SCENE.instantiate() as CountryListElement
	new_element.country = new_country
	new_element.pressed.connect(_on_element_pressed)

	# Determine the position in the list to put this in
	# (they're sorted in alphabetical order).
	var new_country_index: int = 0
	if new_country != null:
		for country in _sorted_countries:
			if (
					country != null
					and new_country.name_or_default()
					< country.name_or_default()
			):
				break
			new_country_index += 1

	_element_container.add_child(new_element)
	_element_container.move_child(new_element, new_country_index)
	_nodes[new_country] = new_element
	_sorted_countries.insert(new_country_index, new_country)


func _remove_element(country: Country) -> void:
	if not _nodes.has(country):
		push_warning("Country doesn't have a corresponding node.")
		return

	if country != null:
		country.name_changed.disconnect(_on_country_name_changed)

	_element_container.remove_child(_nodes[country])
	_nodes.erase(country)
	_sorted_countries.erase(country)

	if _nodes.is_empty():
		_add_empty_list_label()


func _on_element_pressed(element: CountryListElement) -> void:
	country_selected.emit(element.country)


func _on_country_name_changed(country: Country) -> void:
	# Remove it and re-add it so that it gets properly refreshed and sorted
	_remove_element(country)
	_add_element(country)
