class_name CountrySelectPopup
extends VBoxContainer
## Popup that allows the user to select a country from given list.
##
## See also: [GamePopup]

signal country_selected(country: Country)
signal invalidated()

@onready var _country_list := %CountryList as CountryListNode


func setup(countries: Countries, is_no_country_allowed: bool) -> void:
	if not is_node_ready():
		await ready

	_country_list.setup(countries, is_no_country_allowed)
	_country_list.country_selected.connect(country_selected.emit)
	_country_list.country_selected.connect(invalidated.emit.unbind(1))


func buttons() -> Array[String]:
	return ["Cancel"]
