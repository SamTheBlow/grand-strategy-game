class_name Province
extends Node2D


signal selected(this_province: Province)

var id: int

# Nodes
var armies: Armies
var population: Population

# Other data
var links: Array[Province] = []
var _owner_country := Country.new()


func _on_new_turn() -> void:
	_determine_new_owner()
	_auto_recruit()


func _on_shape_clicked() -> void:
	selected.emit(self)


func setup_armies(position_army_host: Vector2) -> void:
	armies = Armies.new()
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
	province_shape().draw_status = 1


func deselect() -> void:
	var shape_node: ProvinceShapePolygon2D = province_shape()
	if shape_node.draw_status == 1:
		for link in links:
			link.deselect()
	shape_node.draw_status = 0


func show_neighbours(display_type: int) -> void:
	for link in links:
		link.show_as_neighbour(display_type)


func show_as_neighbour(display_type: int) -> void:
	province_shape().draw_status = display_type


func is_linked_to(province: Province) -> bool:
	return links.has(province)


static func from_json(json_data: Dictionary, game_state: GameState) -> Province:
	var province := preload("res://scenes/province.tscn").instantiate() as Province
	province.id = json_data["id"]
	province.name = str(province.id)
	var shape: PackedVector2Array = []
	for i in json_data["shape"]["x"].size():
		shape.append(Vector2(
				json_data["shape"]["x"][i], json_data["shape"]["y"][i]
		))
	province.set_shape(shape)
	province.position = (
			Vector2(json_data["position"]["x"], json_data["position"]["y"])
	)
	province.set_owner_country(
			game_state.countries.country_from_id(json_data["owner_country_id"])
	)
	province.setup_population(
			json_data["population"]["size"],
			game_state.rules.population_growth
	)
	province.setup_armies(Vector2(
			json_data["position_army_host_x"],
			json_data["position_army_host_y"]
	))
	province.armies.setup_from_json(json_data["armies"], game_state)
	return province


func as_json() -> Dictionary:
	var links_json: Array = []
	for link in links:
		links_json.append(link.id)
	
	var shape_vertices := Array(province_shape().polygon)
	var shape_vertices_x: Array = []
	var shape_vertices_y: Array = []
	for i in shape_vertices.size():
		shape_vertices_x.append(shape_vertices[i].x)
		shape_vertices_y.append(shape_vertices[i].y)
	
	return {
		"id": id,
		"shape": {"x": shape_vertices_x, "y": shape_vertices_y},
		"position": {"x": position.x, "y": position.y},
		"armies": armies.as_json(),
		"population": population.as_json(),
		"links": links_json,
		"owner_country_id": _owner_country.id,
		"position_army_host_x": armies.position_army_host.x,
		"position_army_host_y": armies.position_army_host.y,
	}


func _determine_new_owner() -> void:
	var new_owner: Country = owner_country()
	for army in armies.armies:
		# If this province's owner has a army here,
		# then it can't be taken by someone else
		if army.owner_country() == owner_country():
			return
		new_owner = army.owner_country()
	set_owner_country(new_owner)


func _auto_recruit() -> void:
	if not has_owner_country():
		return
	
	armies.add_army(Army.quick_setup(
			armies.new_unique_army_id(),
			population.population_size,
			owner_country(),
			preload("res://scenes/army.tscn")
	))
	armies.merge_armies()
