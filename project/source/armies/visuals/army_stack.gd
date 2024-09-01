class_name ArmyStack2D
extends Node2D
## Repositions its children of type [ArmyVisuals2D] such that
## they are all easily visible to the user.
## The first child is at the bottom of the stack,
## and the last child is at the top.


@export var distance_between_armies := Vector2(12.0, -20.0):
	set(value):
		distance_between_armies = value
		_refresh()


func _ready() -> void:
	_refresh()
	child_order_changed.connect(_on_child_order_changed)


func _refresh() -> void:
	var children: Array[Node] = get_children()
	var army_index: int = 0
	for i in children.size():
		if children[i] is not ArmyVisuals2D:
			continue
		var army_visuals := children[i] as ArmyVisuals2D
		army_visuals.move_to(army_index * distance_between_armies)
		army_index += 1


func _on_child_order_changed() -> void:
	_refresh()
