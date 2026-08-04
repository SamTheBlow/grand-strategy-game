class_name InterfaceCountryEdit
extends AppEditorInterface
## The interface in which the user can edit given [Country].

var country: Country

@onready var _preview := %CountryButton as CountryButton
@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	_preview.country = country

	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_load_settings()
	_settings.refresh()

	closed.connect(navigator.open_new_interface.bind(
			InterfaceNavigator.InterfaceType.COUNTRY_LIST,
			project,
			editor_settings
	))


func _unhandled_input(event: InputEvent) -> void:
	super(event)

	if event.is_action_pressed(&"delete"):
		_delete_country()
	if event.is_action_pressed(&"duplicate"):
		_duplicate_country()


func _setting_country_name() -> ItemString:
	return _settings.item.child_items[0] as ItemString


func _setting_country_color() -> ItemColor:
	return _settings.item.child_items[1] as ItemColor


func _setting_country_money() -> ItemInt:
	return _settings.item.child_items[2] as ItemInt


func _load_settings() -> void:
	# Name
	_setting_country_name().value = country.country_name
	_setting_country_name().placeholder_text = country.default_name()
	_setting_country_name().value_changed.connect(_on_name_changed)
	country.name_changed.connect(_on_country_name_changed)

	# Color
	_setting_country_color().value = country.color
	_setting_country_color().value_changed.connect(_on_color_changed)
	country.color_changed.connect(_on_country_color_changed)

	# Amount of money
	_setting_country_money().value = country.money
	_setting_country_money().value_changed.connect(_on_money_changed)
	country.money_changed.connect(_on_country_money_changed)


func _apply_undo_redo_action(
		description: String,
		object: Object,
		property_name: StringName,
		old_value: Variant,
		new_value: Variant
) -> void:
	undo_redo.create_action(description)
	undo_redo.add_do_property(object, property_name, new_value)
	undo_redo.add_undo_property(object, property_name, old_value)
	undo_redo.commit_action()


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


func _delete_country() -> void:
	project.game.countries.undo_redo_remove(
			country,
			undo_redo,
			project.game.world.provinces,
			project.game.world.armies,
			project.game.world.armies_of_each_country,
			project.game.world.armies_in_each_province
	)


func _duplicate_country() -> void:
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


func _on_country_name_changed() -> void:
	_setting_country_name().value = country.country_name


func _on_country_color_changed() -> void:
	_setting_country_color().value = country.color


func _on_country_money_changed(_new_amount: int) -> void:
	_setting_country_money().value = country.money
