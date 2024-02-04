class_name Province
extends Node2D


signal selected(this_province: Province)

var game_mediator: GameMediator

var id: int

# Nodes
var armies: ProvinceArmies
var population: Population
var buildings: Buildings

# Other data
var links: Array[Province] = []
var _owner_country := Country.new()


func _on_new_turn() -> void:
	ProvinceNewOwner.new().update_province_owner(self)
	ArmyRecruitment.new().recruit_in_province(self)


func _on_shape_clicked() -> void:
	selected.emit(self)


func setup_armies(position_army_host: Vector2) -> void:
	armies = ProvinceArmies.new()
	armies.name = "Armies"
	armies.position_army_host = position_army_host
	add_child(armies)


func setup_population(population_size: int, population_growth: bool) -> void:
	population = Population.new()
	population.name = "Population"
	population.population_size = population_size
	
	if population_growth:
		population.add_child(PopulationGrowth.new())
	
	add_child(population)


func setup_buildings() -> void:
	buildings = Buildings.new()
	buildings.name = "Buildings"
	add_child(buildings)


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


func get_shape() -> PackedVector2Array:
	return province_shape().polygon


func set_shape(polygon: PackedVector2Array) -> void:
	province_shape().polygon = polygon


func select() -> void:
	province_shape().outline_type = ProvinceShapePolygon2D.OutlineType.SELECTED


func deselect() -> void:
	var shape_node: ProvinceShapePolygon2D = province_shape()
	if shape_node.outline_type == ProvinceShapePolygon2D.OutlineType.SELECTED:
		for link in links:
			link.deselect()
	shape_node.outline_type = ProvinceShapePolygon2D.OutlineType.NONE


func show_neighbors(outline_type: ProvinceShapePolygon2D.OutlineType) -> void:
	for link in links:
		link.show_as_neighbor(outline_type)


func show_as_neighbor(outline_type: ProvinceShapePolygon2D.OutlineType) -> void:
	province_shape().outline_type = outline_type


func is_linked_to(province: Province) -> bool:
	return links.has(province)
