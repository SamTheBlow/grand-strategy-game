extends Node
## Spawns province visuals for given [GameWorld2D].


@export var _game_world_2d: GameWorld2D

## The province visuals will become children of this node.
@export var container: Node2D

## The scene's root node must extend [ProvinceVisuals2D].
@export var _province_visuals_scene: PackedScene


func _ready() -> void:
	for province in _game_world_2d.provinces.list():
		_add_province(province)


func _add_province(province: Province) -> void:
	var new_province_visuals := (
			_province_visuals_scene.instantiate() as ProvinceVisuals2D
	)
	new_province_visuals.province = province
	container.add_child(new_province_visuals)
