class_name ActionArmyMovement
extends Action


var army: Army
var destination: Province


func _init(army_: Army = null, destination_: Province = null):
	army = army_
	destination = destination_


func play_action():
	var armies_node := destination.get_node("Armies") as Armies
	
	armies_node.add_army(army)
	army.is_active = true
	super()
