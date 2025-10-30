class_name InterfaceCountryList
extends AppEditorInterface
## Shows a list of all countries for the user to edit.
## The list is sorted in alphabetical order.

## Emitted when the user selects an item in the list.
signal item_selected(country_id: int)

const _COUNTRY_ELEMENT_SCENE := preload("uid://bdw77emy4euku") as PackedScene

var _is_setup: bool = false
var _countries: Countries
var _country_factory: Country.Factory

## Maps elements to their corresponding node.
var _nodes: Dictionary[Country, Node] = {}
## Keeps track of the order the countries are in.
var _sorted_countries: Array[Country] = []

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _item_container := %ItemContainer as Node


func _ready() -> void:
	_editor_settings_node.hide()
	super()

	if _is_setup:
		_update()


func setup(countries: Countries, country_factory: Country.Factory) -> void:
	if _is_setup and is_node_ready():
		_countries.added.disconnect(_on_country_added)
		#_countries.removed.disconnect(_on_country_removed)

	_countries = countries
	_country_factory = country_factory
	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	NodeUtils.remove_all_children(_item_container)
	_nodes = {}
	_sorted_countries = []

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
	for country in _sorted_countries:
		if new_country.name_or_default() < country.name_or_default():
			break
		new_country_index += 1

	_item_container.add_child(new_element)
	_item_container.move_child(new_element, new_country_index)
	_nodes[new_country] = new_element
	_sorted_countries.insert(new_country_index, new_country)


func _on_add_button_pressed() -> void:
	_countries.add(_country_factory.new_country())


func _on_element_pressed(element: CountryListElement) -> void:
	item_selected.emit(element.country.id)


func _on_country_added(country: Country) -> void:
	_add_element(country)


func _on_country_removed(country: Country) -> void:
	if _nodes.has(country):
		NodeUtils.delete_node(_nodes[country])
		_nodes.erase(country)
		_sorted_countries.erase(country)
	else:
		push_warning("Country doesn't have a corresponding node.")
