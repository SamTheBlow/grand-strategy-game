class_name MapModeEditorCountry
extends Node
## Left clicking a province on the world map makes it controlled by given
## [Country] or, if it was already controlled by it, unclaims the province.

## This node has no effect when disabled.
var is_enabled: bool = false:
	set(value):
		if is_enabled == value:
			return
		is_enabled = value
		if is_enabled and _is_setup and is_node_ready():
			_update()

var _is_setup: bool = false
var _country: Country

@onready var _province_container := %Provinces as ProvinceVisualsContainer2D


func _ready() -> void:
	if is_enabled and _is_setup:
		_update()


func setup(country: Country) -> void:
	_country = country
	_is_setup = true

	if is_enabled and is_node_ready():
		_update()


func _update() -> void:
	_province_container.remove_all_highlights()


func _on_provinces_unhandled_mouse_event_occured(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
) -> void:
	if not (is_enabled and event is InputEventMouseButton):
		return
	var mouse_button_event := event as InputEventMouseButton

	if (
			mouse_button_event.pressed
			or mouse_button_event.button_index != MOUSE_BUTTON_LEFT
	):
		return

	# Release left click on a province to give control of it to our country
	# or to remove control of it
	if province_visuals.province.owner_country == _country:
		province_visuals.province.owner_country = null
	else:
		province_visuals.province.owner_country = _country

	get_viewport().set_input_as_handled()
