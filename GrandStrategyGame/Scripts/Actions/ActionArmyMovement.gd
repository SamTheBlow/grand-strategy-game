class_name ActionArmyMovement
extends Action


var _province_key: String
var _army_key: String
var _destination_key: String
var _new_army_key: String

var _battles: Array[Battle] = []


func _init(
		province_key: String,
		army_key: String,
		destination_key: String,
		new_army_key: String
) -> void:
	_province_key = province_key
	_army_key = army_key
	_destination_key = destination_key
	_new_army_key = new_army_key


func apply_to(game_state: GameState) -> void:
	var destination_armies: GameStateArray = game_state.armies(_destination_key)
	var army_source: GameStateArray = game_state.army(_province_key, _army_key)
	var army_clone := army_source.clone(_new_army_key)
	
	# Remove the old army from the source province
	game_state.armies(_province_key).data().erase(army_source)
	
	# Add the new army to the destination province
	destination_armies.data().append(army_clone)
	
	#print("Province ", _province_key, " got its army ", _army_key, " moved to province ", _destination_key, " with new key ", _new_army_key)
	super(game_state)


func update_visuals(provinces: Provinces, is_simulation: bool) -> void:
	if is_simulation:
		_update_visuals_simulation(provinces)
		return
	
	var source_province_node: Province = (
			provinces.province_with_key(_province_key)
	)
	var source_armies_node := (
			source_province_node.get_node("Armies") as Armies
	)
	var army_node: Army = source_armies_node.army_with_key(_army_key)
	var destination_province_node: Province = (
			provinces.province_with_key(_destination_key)
	)
	var destination_armies_node := (
			destination_province_node.get_node("Armies") as Armies
	)
	army_node._key = _new_army_key
	destination_armies_node.add_army(army_node)
	
	for battle in _battles:
		battle.update_visuals(provinces)


func _update_visuals_simulation(provinces: Provinces) -> void:
	var source: Province = provinces.province_with_key(_province_key)
	var destination: Province = provinces.province_with_key(_destination_key)
	var source_armies := source.get_node("Armies") as Armies
	var destination_armies := destination.get_node("Armies") as Armies
	
	var moving_army: Army = source_armies.army_with_key(_army_key)
	var source_position: Vector2 = (
			source_armies.position_army_host
			- source_armies.global_position
	)
	var target_position: Vector2 = (
			destination_armies.position_army_host - source.position
	)
	moving_army.play_movement_to(source_position, target_position)
