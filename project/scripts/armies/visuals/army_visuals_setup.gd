extends Node


@export var _game_world_2d: GameWorld2D
@export var _provinces_container: ProvinceVisualsContainer2D

## The scene's root node must extend [ArmyVisuals2D].
@export var _army_visuals_scene: PackedScene


func _ready() -> void:
	for army in _game_world_2d.armies.list():
		_add_army(army)
	
	_game_world_2d.armies.army_added.connect(_on_army_added)


func _add_army(army: Army) -> void:
	var new_army_visuals := _army_visuals_scene.instantiate() as ArmyVisuals2D
	new_army_visuals.army = army
	
	# Why call_deferred?
	# Because we should give time for the province visuals to spawn.
	call_deferred("_on_province_changed", new_army_visuals)
	
	new_army_visuals.province_changed.connect(_on_province_changed)


func _on_army_added(army: Army) -> void:
	_add_army(army)


func _on_province_changed(army_visuals: ArmyVisuals2D) -> void:
	var province_visuals: ProvinceVisuals2D = (
			_provinces_container.visuals_of(army_visuals.army.province())
	)
	if province_visuals == null:
		push_error("Province has no visuals.")
		return
	
	province_visuals.add_army(army_visuals)
