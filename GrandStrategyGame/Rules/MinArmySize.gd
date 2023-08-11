class_name RuleMinArmySize
extends Rule


var minimum_army_size: int = 10


func _ready():
	listen_to = [["Combat", "battle_ended", "_on_battle_ended"]]


# Delete all insufficiently large armies
func _on_battle_ended(game_state: GameState, battle: Battle) -> void:
	var province: GameStateArray = game_state.province(battle._province_key)
	var armies: GameStateArray = province.get_array("armies")
	var army_attacker: GameStateArray = (
		armies.get_array(battle._attacking_army_key)
	)
	if (
		army_attacker != null \
		and army_attacker.get_int("troop_count").data < minimum_army_size
	):
		armies.data().erase(army_attacker)
	var army_defender: GameStateArray = (
		armies.get_array(battle._defending_army_key)
	)
	if (
		army_defender != null \
		and army_defender.get_int("troop_count").data < minimum_army_size
	):
		armies.data().erase(army_defender)


func _on_battle_ended_visuals(provinces: Provinces, battle: Battle) -> void:
	var province: Province = provinces.province_with_key(battle._province_key)
	var armies := province.get_node("Armies") as Armies
	var army_attacker: Army = armies.army_with_key(battle._attacking_army_key)
	if army_attacker != null and army_attacker.troop_count < minimum_army_size:
		army_attacker.queue_free()
	var army_defender: Army = armies.army_with_key(battle._defending_army_key)
	if army_defender != null and army_defender.troop_count < minimum_army_size:
		army_defender.queue_free()


# Prevent players from creating armies that are too small
func action_is_legal(_game_state: GameState, action: Action) -> bool:
	if action is ActionArmySplit:
		var action_split := action as ActionArmySplit
		var partition: Array[int] = action_split._troop_partition
		for p in partition:
			if p < minimum_army_size:
				push_warning("Someone tried to split an army, but at least one of the resulting armies was too small!")
				return false
	return true


# Unused
func _delete_small_armies(game_state: GameState) -> void:
	var provinces: Array[GameStateData] = game_state.provinces().data()
	for province_data in provinces:
		var province := province_data as GameStateArray
		var armies: Array[GameStateData] = province.get_array("armies").data()
		for army_data in armies:
			var army := army_data as GameStateArray
			var troop_count: int = army.get_int("troop_count").data
			if troop_count < minimum_army_size:
				armies.erase(army)
