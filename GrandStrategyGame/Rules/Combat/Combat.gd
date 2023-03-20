class_name RuleCombat
extends Rule


signal battle_started


# Resolve battles at the start of each turn
# This is in case that for example a game starts with battles to be resolved
# Although... how would we determine which army is the attacker? Hmm.
func _on_start_of_turn(provinces: Array[Province], _current_turn: int):
	for province in provinces:
		var armies_node := province.get_node("Armies") as Armies
		var armies: Array[Army] = armies_node.get_alive_armies()
		
		var number_of_armies: int = armies.size()
		for i in number_of_armies:
			for j in range(i + 1, number_of_armies):
				if armies[i].owner_country != armies[j].owner_country:
					resolve_battle(armies[i], armies[j], province)


func _on_action_played(action: Action):
	if action is ActionArmyMovement:
		var action_typed := action as ActionArmyMovement
		resolve_battles(action_typed.army, action_typed.destination)


func resolve_battles(army: Army, province: Province):
	var armies_node := province.get_node("Armies") as Armies
	var armies: Array[Army] = armies_node.get_alive_armies()
	
	var number_of_armies: int = armies.size()
	for i in number_of_armies:
		if army.owner_country != armies[i].owner_country:
			resolve_battle(army, armies[i], province)


func resolve_battle(attacker: Army, defender: Army, province: Province):
	var battle := Attack.new(attacker, defender, province)
	
	# Allow other rules to affect the outcome
	emit_signal("battle_started", battle)
	
	var delta: int = (
		int(attacker.troop_count * battle.attacker_efficiency)
		- defender.troop_count
	)
	if delta > 0:
		attacker.set_troop_count(delta)
		defender.queue_free()
	elif delta < 0:
		attacker.queue_free()
		defender.set_troop_count(-delta)
	else:
		attacker.queue_free()
		defender.queue_free()
