class_name RuleCombat
extends Rule
## Gives the defender a slight advantage in combat.


signal battle_started
signal battle_ended


func _on_action_applied(
		action: Action,
		game_state: GameState
) -> void:
	if action is ActionArmyMovement:
		var movement := action as ActionArmyMovement
		var province_id: int = movement._destination_province_id
		var army_id: int = movement._new_army_id
		movement._battles = resolve_battles(game_state, province_id, army_id)


func resolve_battles(
		game_state: GameState,
		province_id: int,
		army_id: int
) -> Array[Battle]:
	var output: Array[Battle] = []
	
	# TODO make sure this works when there are more than two armies
	var armies: Armies = (
			game_state.world.provinces.province_from_id(province_id).armies
	)
	var army_owner: Country = armies.army_from_id(army_id).owner_country()
	for other_army in armies.armies:
		if other_army.owner_country() != army_owner:
			output.append(resolve_battle(
					game_state,
					province_id,
					army_id,
					other_army.id
			))
	
	return output


func resolve_battle(
		game_state: GameState,
		province_id: int,
		attacker_id: int,
		defender_id: int
) -> Battle:
	var battle := Battle.new(
			province_id,
			attacker_id,
			defender_id
	)
	battle.attacker_efficiency *= 0.9
	
	# Allow other rules to affect the outcome
	emit_signal("battle_started", battle)
	
	battle.apply_to(game_state)
	
	emit_signal("battle_ended", game_state, battle)
	
	return battle
