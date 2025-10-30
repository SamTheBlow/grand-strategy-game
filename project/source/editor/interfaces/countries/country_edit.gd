class_name InterfaceCountryEdit
extends AppEditorInterface
## The interface in which the user can edit given [Country].

signal back_pressed()
signal delete_pressed(country: Country)
signal duplicate_pressed(country: Country)

var country := Country.new()

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


func _load_settings() -> void:
	# Name
	(_settings.item.child_items[0] as ItemString).value = country.country_name
	(_settings.item.child_items[0] as ItemString).placeholder_text = (
			country.default_name()
	)
	(_settings.item.child_items[0] as ItemString).value_changed.connect(
			_on_name_changed
	)

	# Color
	(_settings.item.child_items[1] as ItemColor).value = country.color
	(_settings.item.child_items[1] as ItemColor).value_changed.connect(
			_on_color_changed
	)

	# Amount of money
	(_settings.item.child_items[2] as ItemInt).value = country.money
	(_settings.item.child_items[2] as ItemInt).value_changed.connect(
			_on_money_changed
	)


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(country)


func _on_name_changed(item: ItemString) -> void:
	country.country_name = item.value


func _on_color_changed(item: ItemColor) -> void:
	country.color = item.value


func _on_money_changed(item: ItemInt) -> void:
	country.money = item.value
