class_name Province
extends Node2D


signal clicked(this_province: Province)
signal selected()
signal deselected()

signal owner_country_changed(owner_country: Country)

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

var id: int:
	set(value):
		id = value
		name = str(id)

# Nodes
var army_stack: ArmyStack
var buildings: Buildings

# Positions
var position_army_host: Vector2

# Other data
var links: Array[Province] = []
var _owner_country := Country.new()
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


func show_neighbors(outline_type: ProvinceShapePolygon2D.OutlineType) -> void:
	for link in links:
		link.show_as_neighbor(outline_type)


func show_as_neighbor(outline_type: ProvinceShapePolygon2D.OutlineType) -> void:
	province_shape().outline_type = outline_type


func is_linked_to(province: Province) -> bool:
	return links.has(province)


func is_frontline() -> bool:
	for link in links:
		if link.has_owner_country() and link.owner_country() != _owner_country:
			return true
	return false


func _setup_army_stack() -> void:
	army_stack = ArmyStack.new()
	army_stack.name = "ArmyStack"
	army_stack.position = position_army_host
	army_stack.child_order_changed.connect(army_stack._on_child_order_changed)
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
