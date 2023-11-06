class_name RulePopGrowth
extends Rule
# Basic rule for testing
# Increases a province's population at an exponential rate


func _on_start_of_turn(game_state: GameState) -> void:
	for province in game_state.world.provinces.get_provinces():
		var population_size: int = province.population.population_size
		province.population.population_size += int(population_size * 0.1)
