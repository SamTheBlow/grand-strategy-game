class_name CountrySelectPopup
extends VBoxContainer
## Popup that allows the user to select a country from given list.
##
## See also: [GamePopup]

signal country_selected(country: Country)
signal invalidated()

var _is_setup: bool = false
var _countries: Countries

@onready var _country_list := %CountryList as CountryListNode


func _ready() -> void:
	_country_list.country_selected.connect(_on_country_selected)
	if _is_setup:
		_update()


func setup(countries: Countries) -> void:
	_countries = countries
	_is_setup = true
	if is_node_ready():
		_update()


func buttons() -> Array[String]:
	return ["Cancel"]


func _update() -> void:
	_country_list.setup(_countries, true)


func _on_country_selected(country: Country) -> void:
	country_selected.emit(country)
	# Close the popup
	invalidated.emit()
