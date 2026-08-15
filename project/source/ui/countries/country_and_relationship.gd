class_name CountryAndRelationship
extends Control
## Displays button of given [Country] along with
## its relationship preset with other given country, if applicable.

@export var is_button_enabled: bool = true:
	set(value):
		is_button_enabled = value
		_update_is_button_enabled()

## The minimum size applied to the country button, in pixels.
@export var button_minimum_size := Vector2(0.0, 64.0):
	set(value):
		button_minimum_size = value
		if is_node_ready():
			_country_button.custom_minimum_size = button_minimum_size

## May be null.
var country: Country = null:
	set(value):
		country = value
		_refresh_country_info()
		_refresh_preset_label()

## May be null.
var country_to_relate_to: Country = null:
	set(value):
		country_to_relate_to = value
		_refresh_preset_label()

## Set here the function that you want to call when the button is pressed.
## The function must take one parameter of type [Country], and no return value.
var button_press_outcome: Callable:
	set(value):
		button_press_outcome = value
		_update_button_press_outcome()

@onready var _country_button := %CountryButton as CountryButton
@onready var _no_country := %NoCountry as Control
@onready var _country_name_label := %CountryName as Label
@onready var _preset_root := %PresetRoot as Control
@onready var _label_update := (
		%RelationshipPresetLabelUpdate as RelationshipPresetLabelUpdate
)


func _ready() -> void:
	_refresh_country_info()
	_refresh_preset_label()
	_update_is_button_enabled()
	_update_button_press_outcome()
	_country_button.custom_minimum_size = button_minimum_size


func _update_button_press_outcome() -> void:
	if button_press_outcome.is_null() or not is_node_ready():
		return

	_country_button.pressed.connect(button_press_outcome)


func _refresh_country_info() -> void:
	if not is_node_ready():
		return

	_country_button.country = country

	if country == null:
		_country_button.hide()
		_no_country.show()
		_country_name_label.text = "No country"
	else:
		_no_country.hide()
		_country_button.show()
		_country_name_label.text = country.name_or_default()


func _update_is_button_enabled() -> void:
	if not is_node_ready():
		return

	_country_button.is_button_enabled = is_button_enabled


func _refresh_preset_label() -> void:
	if not is_node_ready():
		return

	_label_update.country = country
	_label_update.country_to_relate_to = country_to_relate_to
	_preset_root.visible = (
			country != null
			and country_to_relate_to != null
			and country != country_to_relate_to
			and country.relationships.with_country(country_to_relate_to)
			.is_preset()
	)
