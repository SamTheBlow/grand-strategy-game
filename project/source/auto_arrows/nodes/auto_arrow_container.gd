class_name AutoArrowContainer
extends Node2D
## Creates new [AutoArrowsNode2D]s and adds them as children.
## Provides utility functions.

var playing_country := PlayingCountry.new(GameTurn.new(Game.new())):
	set(value):
		playing_country = value
		_request_update()

var countries := Countries.new():
	set(value):
		if countries.country_added.is_connected(_create_arrows_node):
			countries.country_added.disconnect(_create_arrows_node)
		countries = value
		_request_update()

## Maps each country to its associated node.
var _list: Dictionary[Country, AutoArrowsNode2D] = {}

@onready var _province_selection := %ProvinceSelection as ProvinceSelection
@onready var _provinces_container := %Provinces as ProvinceVisualsContainer2D


func _ready() -> void:
	_request_update()


## This is so that we only update once per frame.
func _request_update() -> void:
	if not get_tree().process_frame.is_connected(_update):
		get_tree().process_frame.connect(_update, CONNECT_ONE_SHOT)


func _update() -> void:
	if not is_node_ready():
		return

	# Clear existing nodes
	NodeUtils.remove_all_children(self)
	_list = {}

	# Create nodes for the already existing countries
	for country in countries.list():
		_create_arrows_node(country)

	countries.country_added.connect(_create_arrows_node)


func _create_arrows_node(country: Country) -> void:
	var new_node := AutoArrowsNode2D.new()
	new_node.province_visuals_container = _provinces_container
	new_node.auto_arrows = country.auto_arrows
	new_node.init(playing_country, _province_selection)

	add_child(new_node)
	_list[country] = new_node


func _on_preview_arrow_created(preview_arrow: AutoArrowPreviewNode2D) -> void:
	var country: Country = playing_country.country()
	if not _list.has(country):
		_create_arrows_node(country)
	_list[country].add_child(preview_arrow)
