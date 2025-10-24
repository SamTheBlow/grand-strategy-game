class_name PopulationGrowth
## Applies population growth to given province.
##
## See also: [Population]


static func apply(game: Game, province: Province) -> void:
	if (
			not game.rules.population_growth_enabled.value
			or province.population().population_size == 0
			or is_equal_approx(game.rules.population_growth_rate.value, 0.0)
	):
		return

	province.population().population_size += int(
			province.population().population_size
			** game.rules.population_growth_rate.value
	)
