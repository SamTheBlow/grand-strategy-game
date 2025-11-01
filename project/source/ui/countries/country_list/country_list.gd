class_name CountryListNode
extends Control
## Displays a list of countries as buttons.
## Clicking on a country emits a signal.

signal country_selected(country: Country)

const _COUNTRY_ELEMENT_SCENE := preload("uid://bdw77emy4euku") as PackedScene

var _is_setup: bool = false
var _countries: Countries
var _no_country_is_allowed: bool = false

## Maps elements to their corresponding node.
var _nodes: Dictionary[Country, Node] = {}
## Keeps track of the order the countries are in.
var _sorted_countries: Array[Country] = []

@onready var _container := %CountryContainer as Node


func _ready() -> void:
	if _is_setup:
		_update()


## If no_country_is_allowed is set to true, the user will be able to
## select an extra option indicating that they choose none of the countries.
func setup(countries: Countries, no_country_is_allowed: bool) -> void:
	if _is_setup and is_node_ready():
		_countries.added.disconnect(_on_country_added)
		#_countries.removed.disconnect(_on_country_removed)

	_countries = countries
	_no_country_is_allowed = no_country_is_allowed
	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	NodeUtils.remove_all_children(_container)
	_nodes = {}
	_sorted_countries = []

	if _no_country_is_allowed:
		_add_element(null)

	for country in _countries.list():
		_add_element(country)

	_countries.added.connect(_on_country_added)
	#_countries.removed.connect(_on_country_removed)


func _add_element(new_country: Country) -> void:
	if _nodes.has(new_country):
		push_warning("Country already has a corresponding node.")
		return

	var new_element := (
			_COUNTRY_ELEMENT_SCENE.instantiate() as CountryListElement
	)
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

	_container.add_child(new_element)
	_container.move_child(new_element, new_country_index)
	_nodes[new_country] = new_element
	_sorted_countries.insert(new_country_index, new_country)


func _on_element_pressed(element: CountryListElement) -> void:
	country_selected.emit(element.country)


func _on_country_added(country: Country) -> void:
	_add_element(country)


func _on_country_removed(country: Country) -> void:
	if _nodes.has(country):
		NodeUtils.delete_node(_nodes[country])
		_nodes.erase(country)
		_sorted_countries.erase(country)
	else:
		push_warning("Country doesn't have a corresponding node.")
