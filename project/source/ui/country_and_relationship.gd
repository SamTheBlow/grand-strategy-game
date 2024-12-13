class_name CountryAndRelationship
extends Control
## Displays button of given [Country] along with
## its relationship preset with other given country, if applicable.

@export var is_button_enabled: bool = true:
	set(value):
		is_button_enabled = value
		_update_is_button_enabled()

var is_relationship_presets_disabled: bool = true:
	set(value):
		is_relationship_presets_disabled = value
		_refresh_preset_label(0)

var country: Country:
	set(value):
		country = value
		_refresh_country_info()
		_refresh_preset_label(1)

var country_to_relate_to: Country:
	set(value):
		country_to_relate_to = value
		_refresh_preset_label(2)

## Set here the function that you want to call when the button is pressed.
## The function must take one parameter of type [Country], and no return value.
var button_press_outcome: Callable:
	set(value):
		button_press_outcome = value
		_update_button_press_outcome()

@onready var _country_button := %CountryButton as CountryButton
@onready var _country_name_label := %CountryName as Label
@onready var _label_update := (
		%RelationshipPresetLabelUpdate as RelationshipPresetLabelUpdate
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


## Thing to refresh:
## -1 -> (Everything)
##  0 -> is_disabled
##  1 -> country
##  2 -> country_to_relate_to
func _refresh_preset_label(thing_to_refresh: int = -1) -> void:
	if not is_node_ready():
		return

	if thing_to_refresh == -1 or thing_to_refresh == 0:
		_label_update.is_disabled = is_relationship_presets_disabled
	if thing_to_refresh == -1 or thing_to_refresh == 1:
		_label_update.country = country
	if thing_to_refresh == -1 or thing_to_refresh == 2:
		_label_update.country_to_relate_to = country_to_relate_to
