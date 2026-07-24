class_name InterfaceCountryEdit
extends AppEditorInterface
## The interface in which the user can edit given [Country].

signal closed()
signal delete_pressed(country: Country)
signal duplicate_pressed(country: Country)

var country := Country.new()

## This interface automatically closes
## if its country is removed from this countries list.
## May be null, in which case this feature is not used.
var countries: Countries = null:
	set(value):
		if countries != null:
			countries.removed.disconnect(_on_country_removed)

		countries = value

		if countries != null:
			countries.removed.connect(_on_country_removed)

@onready var _preview := %CountryButton as CountryButton
@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_settings.refresh()

	_load_settings()
	_preview.country = country


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"delete"):
		delete_pressed.emit(country)
	if Input.is_action_just_pressed(&"duplicate"):
		duplicate_pressed.emit(country)


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


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(country)


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
