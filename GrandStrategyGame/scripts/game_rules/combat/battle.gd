class_name Battle


var _province_id: int
var _attacking_army_id: int
var _defending_army_id: int
var attacker_efficiency: float = 1.0


func _init(
		province_id: int,
		attacking_army_id: int,
		defending_army_id: int
) -> void:
	_province_id = province_id
	_attacking_army_id = attacking_army_id
	_defending_army_id = defending_army_id


func apply_to(game_state: GameState) -> void:
	var armies: Armies = (
			game_state.world.provinces.province_from_id(_province_id).armies
	)
	var attacker: Army = armies.army_from_id(_attacking_army_id)
	var defender: Army = armies.army_from_id(_defending_army_id)
	
	var delta: int = (
			int(attacker.army_size.current_size() * attacker_efficiency)
			- defender.army_size.current_size()
	)
	#print("Battle occured. Attacker ", attacker.id, " ; Defender ", defender.id, " ; Delta ", delta, " (", "battle was a tie" if delta == 0 else ("attacker won" if delta > 0 else "defender won"), ")")
	if delta > 0:
		# TODO bad code
		attacker.army_size.remove(attacker.army_size.current_size() - delta)
		defender.destroy()
	elif delta < 0:
		attacker.destroy()
		defender.army_size.remove(defender.army_size.current_size() + delta)
	else:
		attacker.destroy()
		defender.destroy()
