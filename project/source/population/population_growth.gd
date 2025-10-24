class_name PopulationGrowth
## Applies population growth to given province.


static func apply(game: Game, province: Province) -> void:
	if (
			not game.rules.population_growth_enabled.value
			or province.population().value == 0
			or is_equal_approx(game.rules.population_growth_rate.value, 0.0)
	):
		return

	province.population().value += int(
			province.population().value
			** game.rules.population_growth_rate.value
	)
