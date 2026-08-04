class_name InterfaceCountryList
extends AppEditorInterface
## Shows a list of all countries for the user to edit.


func _ready() -> void:
	var country_list := %CountryList as CountryListNode
	country_list.setup(project.game.countries, false)
	country_list.country_selected.connect(_on_country_selected)

	closed.connect(navigator.close_interface)


func _on_add_button_pressed() -> void:
	var new_country: Country = Country.Factory.new(project.game).new_country()

	# We need this new country to have a new unique id
	# assigned to it before we can create the undo_redo action
	var countries: Countries = project.game.countries
	countries.add(new_country)

	# Create undo_redo action
	# (don't execute it since we already added the country)
	undo_redo.create_action("Create new country")
	undo_redo.add_do_method(countries.add.bind(new_country))
	undo_redo.add_undo_method(countries.remove.bind(new_country.id))
	undo_redo.commit_action(false)


func _on_country_selected(country: Country) -> void:
	navigator.open_country_edit_interface(
			country.id, project, editor_settings
	)
