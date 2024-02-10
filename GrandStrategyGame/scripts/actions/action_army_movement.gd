class_name ActionArmyMovement
extends Action


var _army_id: int
var _destination_province_id: int


func _init(army_id: int, destination_province_id: int) -> void:
	_army_id = army_id
	_destination_province_id = destination_province_id


func apply_to(game: Game) -> void:
	var army: Army = game.world.armies.army_with_id(_army_id)
	if not army:
		push_warning("Tried to move an army that doesn't exist")
		return
	
	var destination_province: Province = (
			game.world.provinces.province_from_id(_destination_province_id)
	)
	if not destination_province:
		push_warning(
				"Tried to move an army to a province that doesn't exist"
		)
		return
	
	army.play_movement_to(destination_province)
	army.move_to_province(destination_province)
	
	#print("Army ", _army_id, " moved to province ", _destination_province_id)
