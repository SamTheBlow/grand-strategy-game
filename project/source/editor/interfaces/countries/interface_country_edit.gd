class_name InterfaceCountryEdit
extends AppEditorInterface
## The interface in which the user can edit given [Country].

var country: Country


func _ready() -> void:
	(%CountryButton as CountryButton).country = country

	_setup_settings(%Settings as ItemVoidNode)

	closed.connect(navigator.open_new_interface.bind(
			InterfaceNavigator.InterfaceType.COUNTRY_LIST,
			project,
			editor_settings
	))


func _load_settings(settings_item: PropertyTreeItem) -> void:
	# Name
	var item_name := settings_item.child_items[0] as ItemString
	item_name.value = country.country_name
	item_name.placeholder_text = country.default_name()
	item_name.value_changed.connect(_on_name_changed)
	country.name_changed.connect(_on_country_name_changed.bind(item_name))

	# Color
	var item_color := settings_item.child_items[1] as ItemColor
	item_color.value = country.color
	item_color.value_changed.connect(_on_color_changed)
	country.color_changed.connect(_on_country_color_changed.bind(item_color))

	# Amount of money
	var item_money := settings_item.child_items[2] as ItemInt
	item_money.value = country.money
	item_money.value_changed.connect(_on_money_changed)
	country.money_changed.connect(
			_on_country_money_changed.bind(item_money).unbind(1)
	)


func _on_back_button_pressed() -> void:
	closed.emit()


func _on_country_removed(country_removed: Country) -> void:
	if country_removed == country:
		closed.emit()


func _on_edit_relationships_pressed() -> void:
	navigator.open_country_relationships_interface(
			country, project, editor_settings
	)


func _on_edit_notifications_pressed() -> void:
	navigator.open_country_notifications_interface(
			country, project, editor_settings
	)


func _delete() -> void:
	project.game.countries.undo_redo_remove(
			country,
			undo_redo,
			project.game.world.provinces,
			project.game.world.armies,
			project.game.world.armies_of_each_country,
			project.game.world.armies_in_each_province
	)


func _duplicate() -> void:
	# Copies everything except notifications
	var new_country := Country.new()
	new_country.country_name = country.country_name + " (Copy)"
	new_country.color = country.color
	new_country.money = country.money
	# Create a deep duplicate by parsing to raw data and back into a new object
	new_country.relationships = DiplomacyRelationshipParsing.from_raw_data(
			DiplomacyRelationshipParsing.to_raw_array(country.relationships),
			project.game,
			new_country
	)
	new_country.auto_arrows = (
			AutoArrows.from_raw_data(country.auto_arrows.to_raw_data())
	)

	# We need this new country to have a new unique id
	# assigned to it before we can create the undo_redo action
	project.game.countries.add(new_country)

	# Create undo_redo action
	# (don't execute it since we already added the country)
	undo_redo.create_action("Duplicate country")
	undo_redo.add_do_method(project.game.countries.add.bind(new_country))
	undo_redo.add_undo_method(
			project.game.countries.remove.bind(new_country.id)
	)
	undo_redo.commit_action(false)

	navigator.open_country_edit_interface(
			new_country.id, project, editor_settings
	)


func _on_name_changed(item: ItemString) -> void:
	if country.country_name == item.value:
		return

	_apply_undo_redo_action(
			"Change country name",
			country,
			&"country_name",
			country.country_name,
			item.value
	)


func _on_color_changed(item: ItemColor) -> void:
	if country.color == item.value:
		return

	_apply_undo_redo_action(
			"Change country color",
			country,
			&"color",
			country.color,
			item.value
	)


func _on_money_changed(item: ItemInt) -> void:
	if country.money == item.value:
		return

	_apply_undo_redo_action(
			"Change country money",
			country,
			&"money",
			country.money,
			item.value
	)


func _on_country_name_changed(item: ItemString) -> void:
	item.value = country.country_name


func _on_country_color_changed(item: ItemColor) -> void:
	item.value = country.color


func _on_country_money_changed(item: ItemInt) -> void:
	item.value = country.money
