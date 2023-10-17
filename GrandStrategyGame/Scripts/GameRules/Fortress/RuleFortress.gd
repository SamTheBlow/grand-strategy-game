class_name RuleFortress
extends Rule


func _ready() -> void:
	listen_to = [["Combat", "battle_started", "_on_battle_started"]]


func _on_attack(battle: Battle) -> void:
	# Double the defender's defense during a battle
	var game_state: GameState = get_parent().get_parent().game_state
	
	if fortress_is_built(game_state, battle._destination_key):
		battle.attacker_efficiency *= 0.5


func fortress_is_built(
		game_state: GameState,
		province_key: String
) -> bool:
	var province: GameStateArray = game_state.province(province_key)
	var fortress: GameStateArray = province.get_array("fortress")
	return fortress.get_bool("is_built").data
