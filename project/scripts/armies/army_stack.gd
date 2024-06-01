class_name ArmyStack
extends Node
## Class responsible for positioning armies that are at the same location.
## When more than one [Army] is at this stack's location,
## their visuals are positioned such that they are all
## easily visible to the user.
##
## To use, add this node to the scene tree,
## set this node's "position" just like you would with a regular Node2D,
## and then you can start adding [Army] nodes as children of this node.


var position: Vector2
var _distance_between_armies: Vector2 = Vector2(12.0, -20.0)


func _ready() -> void:
	child_order_changed.connect(_on_child_order_changed)
	_on_child_order_changed()


func _on_child_order_changed() -> void:
	var children: Array[Node] = get_children()
	for i in children.size():
		if not children[i] is ArmyVisuals2D:
			continue
		var army_visuals := children[i] as ArmyVisuals2D
		army_visuals.set_location(position + i * _distance_between_armies)
