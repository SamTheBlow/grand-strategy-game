class_name ArmyStack
extends Node
## Class responsible for positioning armies that are at the same location.
## When more than one [Army] is at this stack's location,
## their visuals are positioned such that they are all
## easily visible to the user.
##
## To use, add this node to the scene tree and connect its
## child_order_changed signal to the _on_child_order_changed function.
## Set this node's "position" just like you would with a regular Node2D.
## Then you can start adding [Army] nodes as children of this node.


var position: Vector2
var _distance_between_armies: Vector2 = Vector2(12.0, -20.0)


# TODO automatically connect the signal to this
func _on_child_order_changed() -> void:
	var children: Array[Node] = get_children()
	for i in children.size():
		if not children[i] is Army:
			continue
		var army := children[i] as Army
		if army.animation_is_playing:
			army.target_position = position + i * _distance_between_armies
		else:
			army.global_position = position + i * _distance_between_armies
