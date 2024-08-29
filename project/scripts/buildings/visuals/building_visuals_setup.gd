extends Node
## Spawns building visuals for given [ProvinceVisuals2D].
## Spawns new visuals when a new building is added.


@export var _province_visuals: ProvinceVisuals2D

## The scene's root node must extend [Node2D].
@export var _fortress_visuals_2d_scene: PackedScene


func _ready() -> void:
	if _province_visuals == null or _province_visuals.province == null:
		push_error("Province is null.")
		return
		
	var buildings: Buildings = _province_visuals.province.buildings
	
	for building in buildings.list():
		_add_building(building)
	
	buildings.added.connect(_on_building_added)


func _add_building(building: Building) -> void:
	if building is not Fortress:
		return
	
	var new_fortress := _fortress_visuals_2d_scene.instantiate() as Node2D
	_province_visuals.call_deferred("add_child", new_fortress)
	
	# Wait for the fortress to be added to the scene tree,
	# because the node's position gets ajusted by the parent node
	await new_fortress.ready
	new_fortress.global_position = _province_visuals.global_position_fortress()


func _on_building_added(building: Building) -> void:
	_add_building(building)
