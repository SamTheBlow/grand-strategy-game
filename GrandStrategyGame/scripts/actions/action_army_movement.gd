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


func apply_to(
		_modifier_mediator: ModifierMediator,
		game_state: GameState,
		is_simulation: bool
) -> void:
	var source_province: Province = (
			game_state.world.provinces.province_from_id(_province_id)
	)
	if not source_province:
		push_warning(
				"Tried to move an army from a province that doesn't exist"
		)
		return
	
	var army: Army = source_province.armies.army_from_id(_army_id)
	if not army:
		push_warning("Tried to move an army that doesn't exist")
		return
	
	var destination_province: Province = (
			game_state.world.provinces
			.province_from_id(_destination_province_id)
	)
	if not destination_province:
		push_warning(
				"Tried to move an army to a province that doesn't exist"
		)
		return
	
	if is_simulation:
		# Play the movement animation
		var source_position: Vector2 = (
				source_province.armies.position_army_host
				- source_province.global_position
		)
		var target_position: Vector2 = (
				destination_province.armies.position_army_host
				- source_province.global_position
		)
		army.play_movement_to(source_position, target_position)
		return
	
	# Move the army to the destination province
	army.id = _new_army_id
	destination_province.armies.add_army(army)
	
	#print(
	#		"Province ", _province_id, " got its army ", _army_id,
	#		" moved to province ", _destination_province_id,
	#		" with new id ", _new_army_id
	#)
