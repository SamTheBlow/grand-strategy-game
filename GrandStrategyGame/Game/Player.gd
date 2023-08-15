class_name Player
extends Node


var playing_country: Country
var _key: String


func _ready() -> void:
	var actions_node := Node.new()
	actions_node.name = "Actions"
	add_child(actions_node)


func key() -> String:
	return _key


func get_actions() -> Array[Action]:
	var output: Array[Action] = []
	var actions: Array[Node] = $Actions.get_children()
	for action in actions:
		output.append(action as Action)
	return output
