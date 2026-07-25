class_name InterfaceCountryRelationships
extends AppEditorInterface
## Placeholder interface for editing a [Country]'s relationships.

signal closed()

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


func _on_back_button_pressed() -> void:
	closed.emit()


func _on_country_removed(country_removed: Country) -> void:
	if country_removed == country:
		closed.emit()
