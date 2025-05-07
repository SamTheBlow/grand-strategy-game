class_name WorldDecorationsNode
extends Node2D
## Generates and holds sprites for given [WorldDecoration]s.


func spawn_decorations(decorations: Array[WorldDecoration]) -> void:
	for decoration in decorations:
		add_child(decoration.new_sprite())
