class_name AIPersonalityShy
extends AIPersonality
## In order of priority:
## - Tends to be at war with one reachable nation
##   who is already at war with another nation
## - Tends to not break alliances (unless it has to for previous point)
## - Tends to ask for peace, but not alliances
## - Tends to accept diplomatic offers


func actions(game: Game, _player: GamePlayer) -> Array[Action]:
	var playing_country: Country = game.turn.playing_player().playing_country
	#print("--- Shy ", playing_country.country_name)

	var decisions := AIDecisionUtils.new(game)

	var relative_strengths: Array[float] = (
			decisions.relative_strength_of_countries()
	)

	var country_list: Array[Country] = game.countries.list()

	var reachable_countries: Array[Country] = (
			playing_country.reachable_countries(
					game.world.provinces_of_each_country
					.dictionary[playing_country],
					game.world.provinces
			)
	)
	#print("-- Reachable countries: ")
	#for reachable_country in reachable_countries:
		#print(
				#"(Null)" if reachable_country == null else
				#reachable_country.country_name
		#)

	# Find the current enemies, if any
	var current_enemies: Array[Country] = []
	for country in country_list:
		if not country in reachable_countries:
			decisions.make_peace_with(country)
			continue

		if playing_country.relationships.with_country(country).is_fighting():
			var is_fighting_another_country: bool = false
			for other_country in country_list:
				if (
						other_country == playing_country
						or other_country == country
				):
					continue
				if (
						country.relationships.with_country(other_country)
						.is_fighting()
				):
					is_fighting_another_country = true
					break
			if not is_fighting_another_country:
				decisions.make_peace_with(country)
			else:
				current_enemies.append(country)

	#if current_enemies.size() > 0:
		#print("-- Current enemies: ")
		#for current_enemy in current_enemies:
			#print(current_enemy.country_name)

	# Determine the candidate enemies
	var candidate_enemies: Array[Country] = []
	if current_enemies.size() == 0:
		# From all the reachable countries, only consider non-allies
		# (unless they are all allies, in which case, consider all of them)
		var is_all_allies: bool = true
		for country in reachable_countries:
			if country == null:
				is_all_allies = false
				continue
			if not (
					playing_country.relationships.with_country(country)
					.grants_military_access()
			):
				is_all_allies = false
				candidate_enemies.append(country)
		if is_all_allies:
			candidate_enemies = reachable_countries.duplicate()
	else:
		candidate_enemies = current_enemies.duplicate()

	#if candidate_enemies.size() > 0:
		#print("-- Candidate enemies: ")
		#for candidate_enemy in candidate_enemies:
			#print(candidate_enemy.country_name)

	# Between the candidate enemies, pick the weakest one
	var country_to_attack: Country = null
	var strength_of_country_to_attack: float = 0.0
	for i in country_list.size():
		var candidate_enemy: Country = country_list[i]

		if not candidate_enemy in candidate_enemies:
			continue

		var candidate_strength: float = relative_strengths[i]
		if (
				country_to_attack == null
				or candidate_strength < strength_of_country_to_attack
		):
			country_to_attack = candidate_enemy
			strength_of_country_to_attack = candidate_strength

	if country_to_attack != null:
		#print("Attacking ", country_to_attack.country_name)
		decisions.dismiss_all_offers_from(country_to_attack)
		decisions.break_alliance_with(country_to_attack)
		decisions.declare_war_to(country_to_attack)
	else:
		#print("Not attacking anyone.")
		pass

	for current_enemy in current_enemies:
		if current_enemy == country_to_attack:
			continue
		#print("Asking for peace with ", current_enemy.country_name)
		decisions.make_peace_with(current_enemy)

	#print("---")

	decisions.accept_all_offers()
	return decisions.action_list()
