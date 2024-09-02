class_name AutoArrowContainer
extends Node2D
## Creates new [AutoArrowsNode2D]s and adds them as children.
## Provides utility functions.


@export var province_visuals_container: ProvinceVisualsContainer2D
@export var province_selection: ProvinceSelection

## Make sure to set this before settings countries...
var playing_country: PlayingCountry

var countries: Countries:
	set(value):
		countries = value
		_initialize()

var _list: Array[AutoArrowsNode2D] = []


func _initialize() -> void:
	if countries == null:
		return
	
	# Create nodes for the already existing countries
	for country in countries.list():
		_new_arrows_node(country)
	
	countries.country_added.connect(_on_country_added)


## Creates a new node if the given country doesn't already have one.
func arrows_of_country(country: Country) -> AutoArrowsNode2D:
	for arrows in _list:
		if arrows.country == country:
			return arrows
	return _new_arrows_node(country)


func _new_arrows_node(country: Country) -> AutoArrowsNode2D:
	var new_node := AutoArrowsNode2D.new()
	new_node.country = country
	new_node.province_visuals_container = province_visuals_container
	new_node.init(playing_country, province_selection)
	
	add_child(new_node)
	_list.append(new_node)
	
	return new_node


func _on_country_added(country: Country) -> void:
	_new_arrows_node(country)
