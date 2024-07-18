class_name CountryInfoPopup
extends Control
## The popup that displays information about a given [Country].


var country: Country:
	set(value):
		country = value
		_refresh()

@onready var _country_icon := %CountryIcon as ColorRect
@onready var _name_label := %Name as Label
@onready var _money_label := %Money as Label


func _ready() -> void:
	_refresh()


func buttons() -> Array[String]:
	return ["Close"]


func _refresh() -> void:
	if country == null or not is_node_ready():
		return
	
	_country_icon.color = country.color
	_name_label.text = country.country_name
	_money_label.text = "Money: $" + str(country.money)
