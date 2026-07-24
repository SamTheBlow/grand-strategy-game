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
	var new_country: Country = _country_factory.new_country()

	# We need this new country to have a new unique id
	# assigned to it before we can create the undo_redo action
	_countries.add(new_country)

	# Create undo_redo action
	# (don't execute it since we already added the country)
	undo_redo.create_action("Create new country")
	undo_redo.add_do_method(_countries.add.bind(new_country))
	undo_redo.add_undo_method(_countries.remove.bind(new_country.id))
	undo_redo.commit_action(false)


func _on_country_selected(country: Country) -> void:
	item_selected.emit(country.id)
