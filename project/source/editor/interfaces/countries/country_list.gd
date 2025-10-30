class_name InterfaceCountryList
extends AppEditorInterface
## Shows a list of all countries for the user to edit.
## The list is sorted in alphabetical order.

## Emitted when the user selects an item in the list.
signal item_selected(country_id: int)

var _is_setup: bool = false
var _countries: Countries
var _country_factory: Country.Factory

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _country_list := %CountryList as CountryListNode


func _ready() -> void:
	_editor_settings_node.hide()
	if _is_setup:
		_update()


func setup(countries: Countries, country_factory: Country.Factory) -> void:
	_countries = countries
	_country_factory = country_factory
	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	_country_list.setup(_countries, false)
	if not _country_list.country_selected.is_connected(_on_country_selected):
		_country_list.country_selected.connect(_on_country_selected)


func _on_add_button_pressed() -> void:
	_countries.add(_country_factory.new_country())


func _on_country_selected(country: Country) -> void:
	item_selected.emit(country.id)
