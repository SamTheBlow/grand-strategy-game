class_name RulePopGrowth
extends Rule
# Basic rule for testing
# Increases a province's population at an exponential rate


func _on_start_of_turn(game_state: GameState):
	var provinces: Array[GameStateData] = game_state.provinces().data()
	for province in provinces:
		var population: GameStateInt = (
			game_state.province_population(province.get_key())
		)
		population.data += int(population.data * 0.1)
