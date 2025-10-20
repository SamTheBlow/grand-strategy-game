class_name AutoArrowContainer
extends Node2D
## Creates new [AutoArrowsNode2D]s and adds them as children.
## Provides utility functions.

var _is_setup: bool = false
var _playing_country: PlayingCountry
var _countries: Countries
var _province_selection: ProvinceSelection

## Maps each country to its associated node.
var _list: Dictionary[Country, AutoArrowsNode2D] = {}

@onready var _provinces_container := %Provinces as ProvinceVisualsContainer2D


func _ready() -> void:
	if _is_setup:
		_update()


func setup(
		playing_country: PlayingCountry,
		countries: Countries,
		province_selection: ProvinceSelection
) -> void:
	if _is_setup and is_node_ready():
		_disconnect_signals()

	_playing_country = playing_country
	_countries = countries
	_province_selection = province_selection

	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	# Clear existing nodes
	NodeUtils.remove_all_children(self)
	_list = {}

	# Create nodes for the already existing countries
	for country in _countries.list():
		_create_arrows_node(country)

	# Automatically update in the future
	_connect_signals()


func _create_arrows_node(country: Country) -> void:
	var new_node := AutoArrowsNode2D.new()
	new_node.province_visuals_container = _provinces_container
	new_node.auto_arrows = country.auto_arrows
	new_node.init(_playing_country, _province_selection)

	add_child(new_node)
	_list[country] = new_node


func _connect_signals() -> void:
	_countries.country_added.connect(_create_arrows_node)


func _disconnect_signals() -> void:
	_countries.country_added.disconnect(_create_arrows_node)


func _on_preview_arrow_created(preview_arrow: AutoArrowPreviewNode2D) -> void:
	var country: Country = _playing_country.country()
	if not _list.has(country):
		_create_arrows_node(country)
	_list[country].add_child(preview_arrow)

	# TODO bad code: private function
	_provinces_container.province_mouse_entered.connect(
			preview_arrow._on_province_mouse_entered
	)
	_provinces_container.province_mouse_exited.connect(
			preview_arrow._on_province_mouse_exited
	)
