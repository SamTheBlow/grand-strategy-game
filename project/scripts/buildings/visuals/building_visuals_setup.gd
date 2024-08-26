extends Node
## Spawns building visuals for given [Province].
## Spawns new visuals when a new building is added.


@export var _province: Province:
	set(value):
		_disconnect_signals()
		_province = value
		_connect_signals()
		_initialize()

## The scene's root node must extend [Node2D].
@export var _fortress_visuals_2d_scene: PackedScene


func _ready() -> void:
	_initialize()


func _initialize() -> void:
	if not is_node_ready() or _province == null:
		return
	
	for building in _province.buildings.list():
		_add_building(building)


func _connect_signals() -> void:
	if _province == null:
		return
	
	if not _province.buildings.added.is_connected(_on_building_added):
		_province.buildings.added.connect(_on_building_added)


func _disconnect_signals() -> void:
	if _province == null:
		return
	
	if _province.buildings.added.is_connected(_on_building_added):
		_province.buildings.added.disconnect(_on_building_added)


func _add_building(building: Building) -> void:
	if building is not Fortress:
		return
	
	var new_fortress := _fortress_visuals_2d_scene.instantiate() as Node2D
	_province.call_deferred("add_child", new_fortress)
	
	# Wait for the fortress to be added to the scene tree,
	# because the node's position gets ajusted by the parent node
	await new_fortress.ready
	new_fortress.global_position = _province.global_position_fortress()


func _on_building_added(building: Building) -> void:
	_add_building(building)
