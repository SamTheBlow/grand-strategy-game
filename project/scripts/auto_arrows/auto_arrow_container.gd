class_name AutoArrowContainer
extends Node
## Contains all the [AutoArrowsNode2D].
## Provides utility functions.
## Note that currently, items are not meant to be removed.


var game: Game

var _list: Array[AutoArrowsNode2D] = []


# DANGER this only works if you assume that countries
# are never added or removed later in the game
func _ready() -> void:
	for country in game.countries.countries:
		_new_arrows_node(country)


func add(auto_arrows_node: AutoArrowsNode2D) -> void:
	add_child(auto_arrows_node)
	_list.append(auto_arrows_node)


## Creates a new node if the given country doesn't already have one.
func arrows_of_country(country: Country) -> AutoArrowsNode2D:
	for arrows in _list:
		if arrows.country() == country:
			return arrows
	return _new_arrows_node(country)


func _new_arrows_node(country: Country) -> AutoArrowsNode2D:
	var new_node := AutoArrowsNode2D.new()
	new_node.init(game, country)
	add(new_node)
	return new_node
