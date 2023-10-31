class_name Battle


var _province_key: String
var _attacking_army_key: String
var _defending_army_key: String
var attacker_efficiency: float = 1.0

# TODO bad code
var _delta: int


func _init(
		province_key: String,
		attacking_army_key: String,
		defending_army_key: String
) -> void:
	_province_key = province_key
	_attacking_army_key = attacking_army_key
	_defending_army_key = defending_army_key


func apply_outcome(game_state: GameState) -> void:
	var attacker_troop_count: GameStateInt = (
			game_state.army_troop_count(_province_key, _attacking_army_key)
	)
	var defender_troop_count: GameStateInt = (
			game_state.army_troop_count(_province_key, _defending_army_key)
	)
	
	var armies_data: Array[GameStateData] = (
			game_state.armies(_province_key).data()
	)
	var attacking_army_data: GameStateData = (
			game_state.army(_province_key, _attacking_army_key)
	)
	var defending_army_data: GameStateData = (
			game_state.army(_province_key, _defending_army_key)
	)
	
	_delta = (
			int(attacker_troop_count.data * attacker_efficiency)
			- defender_troop_count.data
	)
	#print("Battle occured. Attacker ", _attacking_army_key, " ; Defender ", _defending_army_key, " ; Delta ", _delta, " (", "battle was a tie" if _delta == 0 else ("attacker won" if _delta > 0 else "defender won"), ")")
	if _delta > 0:
		attacker_troop_count.data = _delta
		armies_data.erase(defending_army_data)
	elif _delta < 0:
		armies_data.erase(attacking_army_data)
		defender_troop_count.data = -_delta
	else:
		armies_data.erase(attacking_army_data)
		armies_data.erase(defending_army_data)


func update_visuals(provinces: Provinces) -> void:
	var province_node: Province = provinces.province_with_key(_province_key)
	var armies_node := province_node.get_node("Armies") as Armies
	var attacker: Army = armies_node.army_with_key(_attacking_army_key)
	var defender: Army = armies_node.army_with_key(_defending_army_key)
	
	if _delta > 0:
		# TODO bad code
		attacker._army_size.remove(attacker._army_size.current_size() - _delta)
		defender.destroy()
	elif _delta < 0:
		attacker.destroy()
		defender._army_size.remove(defender._army_size.current_size() + _delta)
	else:
		attacker.destroy()
		defender.destroy()
