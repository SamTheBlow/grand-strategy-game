class_name ActionArmyMovement
extends Action


var _province_id: int
var _army_id: int
var _destination_province_id: int
var _new_army_id: int

var _battles: Array[Battle] = []


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


func apply_to(game_state: GameState) -> void:
	var armies: Armies = (
			game_state.world.provinces.province_from_id(_province_id).armies
	)
	var army: Army = armies.army_from_id(_army_id)
	var destination_armies: Armies = (
			game_state.world.provinces
			.province_from_id(_destination_province_id).armies
	)
	
	# Move the army to the destination province
	army.id = _new_army_id
	destination_armies.add_army(army)
	
	# Make the battles happen
	for battle in _battles:
		battle.apply_to(game_state)
	
	#print("Province ", _province_id, " got its army ", _army_id, " moved to province ", _destination_province_id, " with new id ", _new_army_id)
	super(game_state)


func simulate_to(game_state: GameState) -> void:
	# Play the movement animation
	var source: Province = (
			game_state.world.provinces.province_from_id(_province_id)
	)
	var destination: Province = (
			game_state.world.provinces
			.province_from_id(_destination_province_id)
	)
	var source_armies: Armies = source.armies
	var destination_armies: Armies = destination.armies
	
	var moving_army: Army = source_armies.army_from_id(_army_id)
	var source_position: Vector2 = (
			source_armies.position_army_host - source_armies.global_position
	)
	var target_position: Vector2 = (
			destination_armies.position_army_host - source.position
	)
	moving_army.play_movement_to(source_position, target_position)
