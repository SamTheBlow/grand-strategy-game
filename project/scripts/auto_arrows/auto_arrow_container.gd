class_name AutoArrowContainer
extends Node
## Contains all the [AutoArrowsNode2D].
## Provides utility functions.
## Note that currently, items are not meant to be removed.


## Meant to be set only once, before entering the scene tree.
## Not meant to be null.
var game: Game

var _list: Array[AutoArrowsNode2D] = []


func _ready() -> void:
	if game == null:
		push_error("Game is null.")
		return
	
	# Create nodes for the already existing countries
	for country in game.countries.list():
		_new_arrows_node(country)
	
	game.countries.country_added.connect(_on_country_added)


func add(auto_arrows_node: AutoArrowsNode2D) -> void:
	add_child(auto_arrows_node)
	_list.append(auto_arrows_node)


## Creates a new node if the given country doesn't already have one.
func arrows_of_country(country: Country) -> AutoArrowsNode2D:
	for arrows in _list:
		if arrows.country == country:
			return arrows
	return _new_arrows_node(country)


func _new_arrows_node(country: Country) -> AutoArrowsNode2D:
	var new_node := AutoArrowsNode2D.new()
	new_node.country = country
	new_node.init(game)
	add(new_node)
	return new_node


func _on_country_added(country: Country) -> void:
	_new_arrows_node(country)
