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
		var province_key: String = movement._destination_key
		var army_key: String = movement._new_army_key
		movement._battles = resolve_battles(game_state, province_key, army_key)


func resolve_battles(
	game_state: GameState,
	province_key: String,
	army_key: String
) -> Array[Battle]:
	var output: Array[Battle] = []
	
	# We use a duplicate of the army data because when we resolve battles,
	# there is a chance that we erase armies from the original array.
	var armies: Array[GameStateData] = (
		(game_state.armies(province_key).duplicate() as GameStateArray).data()
	)
	var army_owner: String = game_state.army_owner(province_key, army_key).data
	var number_of_armies: int = armies.size()
	for i in number_of_armies:
		var other_army_key: String = armies[i].get_key()
		var other_army_owner: String = (
			game_state.army_owner(province_key, other_army_key).data
		)
		if other_army_owner != army_owner:
			output.append(resolve_battle(
				game_state,
				province_key,
				army_key,
				other_army_key
			))
		
		# If the army died in battle, stop
		if game_state.armies(province_key).index_of(army_key) == -1:
			break
	
	return output


func resolve_battle(
	game_state: GameState,
	province_key: String,
	attacker_key: String,
	defender_key: String
) -> Battle:
	var battle := Battle.new(
		province_key,
		attacker_key,
		defender_key
	)
	battle.attacker_efficiency *= 0.9
	
	# Allow other rules to affect the outcome
	emit_signal("battle_started", battle)
	
	battle.apply_outcome(game_state)
	
	emit_signal("battle_ended", game_state, battle)
	
	return battle
