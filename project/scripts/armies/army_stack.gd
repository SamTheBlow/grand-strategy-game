class_name ArmyStack
extends Node
## Class responsible for positioning armies that are at the same location.


var position: Vector2
var _distance_between_armies: Vector2 = Vector2(12.0, -20.0)


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
