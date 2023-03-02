extends Node
class_name Player

var playing_country:Country

func _ready():
	var actions_node = Node.new()
	actions_node.name = "Actions"
	add_child(actions_node)

func init(playing_country_:Country):
	playing_country = playing_country_

func get_actions() -> Array:
	return $Actions.get_children()
