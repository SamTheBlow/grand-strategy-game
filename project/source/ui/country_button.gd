class_name CountryButton
extends Control
## Button colored after given [Country].
## Draws a black outline around the button when enabled.
## Clicking on it emits a signal with the country as argument.

signal pressed(country: Country)

@export var has_black_outline: bool = false:
	set(value):
		has_black_outline = value
		queue_redraw()

@export var is_button_enabled: bool = true:
	set(value):
		is_button_enabled = value
		_update_button_enabled()

## May be null.
var country: Country = null:
	set(value):
		if country != null:
			country.color_changed.disconnect(_refresh)
		country = value
		_refresh()
		if country != null:
			country.color_changed.connect(_refresh)

@onready var _country_icon := %CountryIcon as ColorRect
@onready var _button := %Button as Button


func _ready() -> void:
	_refresh()
	_update_button_enabled()


func _draw() -> void:
	if not has_black_outline:
		return

	var outline_width: int = 1

	draw_rect(
			Rect2(
					position
					+ _country_icon.position - outline_width * Vector2.ONE,
					_country_icon.size + 2 * outline_width * Vector2.ONE
			),
			Color.BLACK
	)


func _refresh() -> void:
	if not is_node_ready():
		return

	if country == null:
		_country_icon.hide()
	else:
		_country_icon.show()
		_country_icon.color = country.color


func _update_button_enabled() -> void:
	if not is_node_ready():
		return

	_button.disabled = not is_button_enabled
	_button.visible = is_button_enabled


func _on_button_pressed() -> void:
	pressed.emit(country)
