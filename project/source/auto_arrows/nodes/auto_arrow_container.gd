class_name AutoArrowContainer
extends Node2D
## Creates new [AutoArrowsNode2D]s and adds them as children.
## Only shows one country's arrows at a time.

var _is_setup: bool = false
var _countries: Countries

## Maps each country to its associated node.
var _list: Dictionary[Country, AutoArrowsNode2D] = {}
## Keeps track of the currently visible arrows. May be null.
var _visible_node: Node2D = null

@onready var _provinces_container := %Provinces as ProvinceVisualsContainer2D


func _ready() -> void:
	if _is_setup:
		_update()


func setup(countries: Countries) -> void:
	if _is_setup and is_node_ready():
		_countries.added.disconnect(_create_arrows_node)

	_countries = countries
	_is_setup = true

	if is_node_ready():
		_update()


## Argument may be null, in which case this hides all countries.
func show_country(country: Country) -> void:
	if _visible_node != null:
		_visible_node.hide()

	if not _list.has(country):
		return
	_visible_node = _list[country]
	_visible_node.show()


func _update() -> void:
	# Clear existing nodes
	NodeUtils.remove_all_children(self)
	_list = {}
	_visible_node = null

	# Create nodes for the already existing countries
	for country in _countries.list():
		_create_arrows_node(country)

	# Connect signals for automatic updates
	_countries.added.connect(_create_arrows_node)


func _create_arrows_node(country: Country) -> void:
	var new_node := AutoArrowsNode2D.new()
	new_node.province_visuals_container = _provinces_container
	new_node.auto_arrows = country.auto_arrows
	new_node.hide()

	add_child(new_node)
	_list[country] = new_node


func _on_preview_arrow_created(preview_arrow: AutoArrowPreviewNode2D) -> void:
	var country: Country = preview_arrow.country()
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
