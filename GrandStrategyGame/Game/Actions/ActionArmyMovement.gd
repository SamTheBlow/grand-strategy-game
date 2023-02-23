extends "res://Game/Actions/Action.gd"
class_name ActionArmyMovement

var army:Army
var destination:Province

func _init(army_:Army = null, destination_:Province = null):
	army = army_
	destination = destination_

func play_action():
	destination.add_troops(army)
	army.is_active = true
	.play_action()
