class_name PopulationGrowth
## Applies population growth to a [Population],
## depending on provided [GameRules].


func apply(game_rules: GameRules, population: Population) -> void:
	if not game_rules.population_growth_enabled:
		return
	
	if (
			population.population_size == 0
			or is_equal_approx(game_rules.population_growth_rate, 0.0)
	):
		return
	
	var exponent: float = -(1.0 - game_rules.population_growth_rate)
	var growth_rate: float = population.population_size ** exponent
	
	population.population_size += int(
			population.population_size * growth_rate
	)
