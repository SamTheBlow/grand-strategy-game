class_name ActionArmyMovement
extends Action


var _province_id: int
var _army_id: int
var _destination_province_id: int
var _new_army_id: int


func _init(
		province_id: int,
		army_id: int,
		destination_province_id: int,
		new_army_id: int
) -> void:
	_province_id = province_id
	_army_id = army_id
	_destination_province_id = destination_province_id
	_new_army_id = new_army_id


func apply_to(game: Game) -> void:
	var source_province: Province = (
			game.world.provinces.province_from_id(_province_id)
	)
	if not source_province:
		push_warning(
				"Tried to move an army from a province that doesn't exist"
		)
		return
	
	var army: Army = game.world.armies.army_with_id(_army_id, source_province)
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
	army.id = _new_army_id
	army.name = str(army.id)
	army.move_to_province(destination_province)
	
	#print(
	#		"Province ", _province_id, " got its army ", _army_id,
	#		" moved to province ", _destination_province_id,
	#		" with new id ", _new_army_id
	#)
