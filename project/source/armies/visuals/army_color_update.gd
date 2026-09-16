class_name ArmyColorUpdate
extends Node
## Ensures an army's visuals always use the color of its country.

@export var _army_sprite: Sprite2D
@export var _army_size_box: ArmySizeBox

var _owner_country: Country:
	set(value):
		if _owner_country != null:
			_owner_country.color_changed.disconnect(_refresh)

		_owner_country = value
		_refresh()

		_owner_country.color_changed.connect(_refresh)


func setup(army: Army) -> void:
	_set_owner_country(army)
	army.allegiance_changed.connect(
			_set_owner_country, ConnectFlags.CONNECT_APPEND_SOURCE_OBJECT
	)


func _refresh() -> void:
	_army_sprite.modulate = _owner_country.color
	_army_size_box.color = _owner_country.color


func _set_owner_country(army: Army) -> void:
	_owner_country = army.owner_country
