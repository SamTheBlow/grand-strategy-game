class_name Province
extends Node2D
## In a game, a province represents a certain area on the world map.
## It may be of any size or shape, and
## it may or may not be under the control of a [Country].
##
## This class has many responsibilities, as many game mechanics
## involve their presence on a province:
## [Army], [Population], [Building], [IncomeMoney].
##
## See [method GameFromJSON._load_province]
## to see how to initialize a new province.


signal clicked(this_province: Province)
signal selected()
signal deselected()

signal owner_country_changed(owner_country: Country)

## External reference
var game: Game:
	set(value):
		if game:
			clicked.disconnect(game._on_province_clicked)
			selected.disconnect(game._on_province_selected)
			deselected.disconnect(game._on_province_deselected)
			game.turn.turn_changed.disconnect(_on_new_turn)
		
		game = value
		
		clicked.connect(game._on_province_clicked)
		selected.connect(game._on_province_selected)
		deselected.connect(game._on_province_deselected)
		game.turn.turn_changed.connect(_on_new_turn)

## All provinces must have a unique id for the purposes of saving/loading.
## The node's name always matches its id.
var id: int:
	set(value):
		id = value
		name = str(id)

# Nodes
var army_stack: ArmyStack
var buildings: Buildings

# Positions
## Where this province's [ArmyStack] will be positioned,
## relative to this province's position.
var position_army_host: Vector2

# Other data
## A list of all the provinces that are
## neighboring this province, e.g. when moving armies.
var links: Array[Province] = []
## The [Country] in control of this province.
var _owner_country := Country.new()
## How much money (the in-game resource)
## this province generates per [GameTurn].
var _income_money: IncomeMoney
var population: Population


## To be called when this node is created.
func init() -> void:
	_setup_army_stack()
	_setup_buildings()


func province_shape() -> ProvinceShapePolygon2D:
	return $Shape as ProvinceShapePolygon2D


func has_owner_country() -> bool:
	return _owner_country.id >= 0


func owner_country() -> Country:
	return _owner_country


# TODO use setters
func set_owner_country(country: Country) -> void:
	if country == _owner_country:
		return
	_owner_country = country
	
	var shape_node: ProvinceShapePolygon2D = province_shape()
	shape_node.color = country.color


func income_money() -> IncomeMoney:
	return _income_money


func get_shape() -> PackedVector2Array:
	return province_shape().polygon


# TODO use setters?
func set_shape(polygon: PackedVector2Array) -> void:
	province_shape().polygon = polygon


func select() -> void:
	province_shape().outline_type = ProvinceShapePolygon2D.OutlineType.SELECTED
	selected.emit()


func deselect() -> void:
	var shape_node: ProvinceShapePolygon2D = province_shape()
	if shape_node.outline_type == ProvinceShapePolygon2D.OutlineType.SELECTED:
		for link in links:
			link.deselect()
		deselected.emit()
	shape_node.outline_type = ProvinceShapePolygon2D.OutlineType.NONE


## Outlines all of this province's links with given outline type.
func show_neighbors(outline_type: ProvinceShapePolygon2D.OutlineType) -> void:
	for link in links:
		link.show_as_neighbor(outline_type)


## Outlines this province's shape with given outline type.
func show_as_neighbor(outline_type: ProvinceShapePolygon2D.OutlineType) -> void:
	province_shape().outline_type = outline_type


func is_linked_to(province: Province) -> bool:
	return links.has(province)


## Returns true if any of this province's links
## are controlled by a different [Country].
func is_frontline() -> bool:
	for link in links:
		if link.has_owner_country() and link.owner_country() != _owner_country:
			return true
	return false


func _setup_army_stack() -> void:
	army_stack = ArmyStack.new()
	army_stack.name = "ArmyStack"
	army_stack.position = position_army_host
	add_child(army_stack)


func _setup_buildings() -> void:
	buildings = Buildings.new()
	buildings.name = "Buildings"
	add_child(buildings)


func _on_new_turn(_turn: int) -> void:
	ArmyReinforcements.new().reinforce_province(self)
	_owner_country.money += _income_money.total()


func _on_shape_clicked() -> void:
	clicked.emit(self)
