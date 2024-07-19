class_name CountryAndRelationship
extends Control


@export var is_button_enabled: bool = true:
	set(value):
		is_button_enabled = value
		_update_is_button_enabled()

var country: Country:
	set(value):
		country = value
		_refresh()

var is_relationship_presets_enabled: bool = false:
	set(value):
		is_relationship_presets_enabled = value
		_refresh_relationship_preset()

var country_to_relate_to: Country:
	set(value):
		country_to_relate_to = value
		_refresh_relationship_preset()

## Set here the function that you want to call when the button is pressed.
## The function must take one parameter of type [Country], and no return value.
var button_press_outcome: Callable:
	set(value):
		button_press_outcome = value
		_update_button_press_outcome()

@onready var _country_button := %CountryButton as CountryButton
@onready var _country_name_label := %CountryName as Label
@onready var _relationship_preset_label := %RelationshipPreset as Label


func _ready() -> void:
	_refresh()
	_update_is_button_enabled()
	_update_button_press_outcome()


func _update_button_press_outcome() -> void:
	if button_press_outcome.is_null() or not is_node_ready():
		return
	
	_country_button.pressed.connect(button_press_outcome)


func _refresh() -> void:
	if country == null or not is_node_ready():
		return
	
	_country_button.country = country
	_country_name_label.text = country.country_name
	_refresh_relationship_preset()


func _refresh_relationship_preset() -> void:
	if not is_node_ready():
		return
	
	if (
			not is_relationship_presets_enabled
			or country == null
			or country_to_relate_to == null
			or country == country_to_relate_to
	):
		_relationship_preset_label.hide()
		return
	
	var relationship_preset: DiplomacyPreset = (
			country_to_relate_to.relationships.with_country(country).preset()
	)
	
	_relationship_preset_label.add_theme_color_override(
			"font_color", relationship_preset.color
	)
	_relationship_preset_label.text = "(" + relationship_preset.name + ")"
	_relationship_preset_label.show()


func _update_is_button_enabled() -> void:
	if not is_node_ready():
		return
	
	_country_button.is_button_enabled = is_button_enabled
