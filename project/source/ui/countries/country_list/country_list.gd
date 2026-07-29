class_name CountryListNode
extends Control
## Displays a list of countries as buttons.
## Clicking on a country emits a signal.

signal country_selected(country: Country)

const _ELEMENT_SCENE := preload("uid://bdw77emy4euku") as PackedScene

## May be null, in which case the list is empty.
var countries: Countries = null:
	set(value):
		if countries != null:
			countries.added.disconnect(_on_country_added)
			countries.removed.disconnect(_on_country_removed)

		countries = value
		_refresh()

		if countries != null:
			countries.added.connect(_on_country_added)
			countries.removed.connect(_on_country_removed)

## If true, then there is an extra option in the list "No Country".
var no_country_is_allowed: bool = false

## Maps elements to their corresponding node.
var _nodes: Dictionary[Country, Node] = {}
## Keeps track of the order the countries are in.
var _sorted_countries: Array[Country] = []

@onready var _element_container := %CountryContainer as Node


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return

	# Clear everything
	NodeUtils.delete_all_children(_element_container)
	_nodes.clear()
	for country in _sorted_countries:
		country.name_changed.disconnect(_on_country_name_changed)
	_sorted_countries.clear()

	if countries == null:
		return

	if no_country_is_allowed:
		_add_element(null)

	for country in countries.list():
		_add_element(country)


func _add_element(new_country: Country) -> void:
	if _nodes.has(new_country):
		push_warning("Country already has a corresponding node.")
		return

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


func _on_element_pressed(element: CountryListElement) -> void:
	country_selected.emit(element.country)


func _on_country_added(country: Country) -> void:
	_add_element(country)


func _on_country_removed(country: Country) -> void:
	if not _nodes.has(country):
		push_warning("Country doesn't have a corresponding node.")
		return

	if country != null:
		country.name_changed.disconnect(_on_country_name_changed)

	_element_container.remove_child(_nodes[country])
	_nodes.erase(country)
	_sorted_countries.erase(country)


func _on_country_name_changed(country: Country) -> void:
	# Remove it and re-add it so that it gets properly refreshed and sorted
	_on_country_removed(country)
	_on_country_added(country)
