class_name ArmyListElement
extends Control
## A button representing an [Army].

signal pressed(this: ArmyListElement)

var army: Army
var playing_country: PlayingCountry

@onready var _preview := %ArmyPreview as ArmyPreviewNode
@onready var _country_button := %CountryButton as CountryButton


func _ready() -> void:
	_preview.setup(army, playing_country)

	_refresh_country_button()
	army.allegiance_changed.connect(_refresh_country_button.unbind(1))


func _refresh_country_button() -> void:
	_country_button.country = army.owner_country


func _on_button_pressed() -> void:
	pressed.emit(self)
