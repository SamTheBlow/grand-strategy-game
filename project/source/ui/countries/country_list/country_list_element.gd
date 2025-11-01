class_name CountryListElement
extends Control
## A button representing a [Country].

signal pressed(this: CountryListElement)

## May be null.
var country: Country = null:
	set(value):
		country = value
		if is_node_ready():
			_update()

@onready var _contents := %Contents as CountryAndRelationship


func _ready() -> void:
	_update()


func _update() -> void:
	_contents.country = country


func _on_button_pressed() -> void:
	pressed.emit(self)
