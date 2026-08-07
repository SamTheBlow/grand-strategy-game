class_name InterfaceCountryNotifications
extends AppEditorInterface
## Placeholder interface for editing a [Country]'s notifications.

var country := Country.new()


func _ready() -> void:
	project.game.countries.removed.connect(_on_country_removed)

	closed.connect(_on_closed)


## Returns to the country edit interface,
## or to the country list if the country no longer exists.
func _on_closed() -> void:
	if project.game.countries.country_from_id(country.id) != null:
		navigator.open_country_edit_interface(country, project, editor_settings)
	else:
		navigator.open_new_interface(
				InterfaceNavigator.Type.COUNTRY_LIST, project, editor_settings
		)


func _on_country_removed(country_removed: Country) -> void:
	if country_removed == country:
		closed.emit()
