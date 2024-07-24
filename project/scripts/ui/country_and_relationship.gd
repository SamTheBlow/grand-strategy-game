class_name CountryAndRelationship
extends Control


@export var is_button_enabled: bool = true:
	set(value):
		is_button_enabled = value
		_update_is_button_enabled()

var country: Country:
	set(value):
		country = value
		_refresh_country_info()
		_refresh_preset_label()

var is_relationship_presets_enabled: bool = false:
	set(value):
		is_relationship_presets_enabled = value
		_refresh_preset_label()

var country_to_relate_to: Country:
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
@onready var _country_name_label := %CountryName as Label
@onready var _relationship_preset_label := (
		%RelationshipPreset as RelationshipPresetLabel
)


func _ready() -> void:
	_refresh_country_info()
	_refresh_preset_label()
	_update_is_button_enabled()
	_update_button_press_outcome()


func _update_button_press_outcome() -> void:
	if button_press_outcome.is_null() or not is_node_ready():
		return
	
	_country_button.pressed.connect(button_press_outcome)


func _refresh_country_info() -> void:
	if country == null or not is_node_ready():
		return
	
	_country_button.country = country
	_country_name_label.text = country.country_name


func _update_is_button_enabled() -> void:
	if not is_node_ready():
		return
	
	_country_button.is_button_enabled = is_button_enabled


func _refresh_preset_label() -> void:
	if not is_node_ready():
		return
	
	if (
			not is_relationship_presets_enabled
			or country == null
			or country_to_relate_to == null
			or country == country_to_relate_to
	):
		_relationship_preset_label.relationship = null
		return
	
	_relationship_preset_label.relationship = (
			country.relationships.with_country(country_to_relate_to)
	)
