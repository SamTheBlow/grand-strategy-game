class_name CountryButtonProvinceUpdate
extends Node
## Updates given [CountryButton] so that it always
## shows given [Province]'s owner [Country] even after it changes.
## Hides the button when either given province or its owner country is null.


@export var country_button: CountryButton

var province: Province:
	set(value):
		if province == value:
			return
		_disconnect_signals()
		province = value
		_connect_signals()
		_refresh()


func _refresh() -> void:
	if province == null or province.owner_country == null:
		country_button.hide()
		return
	
	country_button.country = province.owner_country
	country_button.show()


func _connect_signals() -> void:
	if not province:
		return
	
	if not province.owner_changed.is_connected(_on_province_owner_changed):
		province.owner_changed.connect(_on_province_owner_changed)


func _disconnect_signals() -> void:
	if not province:
		return
	
	if province.owner_changed.is_connected(_on_province_owner_changed):
		province.owner_changed.disconnect(_on_province_owner_changed)


func _on_province_owner_changed(_province: Province) -> void:
	_refresh()
