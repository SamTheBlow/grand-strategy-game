class_name CountryButton
extends Control
## A button that shows a [Country]'s color.
## Clicking on it emits a signal.


signal pressed(country: Country)

@export var has_black_outline: bool = false:
	set(value):
		has_black_outline = value
		queue_redraw()

## The country represented by this button.
var country: Country:
	set(value):
		country = value
		_refresh()

@onready var _country_icon := %CountryIcon as ColorRect


func _ready() -> void:
	_refresh()


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
	if country == null or not is_node_ready():
		return
	
	_country_icon.color = country.color


func _on_button_pressed() -> void:
	pressed.emit(country)
