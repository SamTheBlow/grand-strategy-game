class_name Fortress
extends Node2D


static func new_fortress(
		scene: PackedScene,
		input_position: Vector2
) -> Fortress:
	var fortress := scene.instantiate() as Fortress
	fortress.name = "Fortress"
	fortress.position = input_position + Vector2(80.0, 56.0)
	return fortress
