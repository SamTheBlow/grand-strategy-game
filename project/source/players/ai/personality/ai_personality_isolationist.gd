class_name AIPersonalityIsolationist
extends AIPersonality
## In order of priority:
## - Tends to go to war with the weakest neighboring nation,
##   but only when much stronger than that nation and its nearby allies
## - Tends to send & accept peace/alliances with all nations


func actions(game: Game, _player: GamePlayer) -> Array[Action]:
	var playing_country: Country = game.turn.playing_player().playing_country
	#print("--- Isolationist ", playing_country.name_or_default())

	var decisions := AIDecisionUtils.new(game)

	var relative_strengths: Array[float] = (
			decisions.relative_strength_of_countries()
	)

	var country_list: Array[Country] = game.countries.list()

	# Get my relative strength
	var my_relative_strength: float = 0.0
	for i in country_list.size():
		if country_list[i] == playing_country:
			my_relative_strength = relative_strengths[i]
			break

	var candidate_countries: Array[Country] = []
	var neighbors: Array[Country] = playing_country.neighboring_countries(
			game.world.provinces_of_each_country.of_country(playing_country),
			game.world.provinces
	)

	for i in country_list.size():
		var target_country: Country = country_list[i]

		if target_country == playing_country:
			continue

		# Compare the country's strength with ours
		var their_relative_strength: float = relative_strengths[i]
		# Add up the strength of the country's allies
		# (only the ones neighboring us)
		for j in country_list.size():
			var other_country: Country = country_list[j]

			if (
					other_country == playing_country
					or other_country == target_country
					or not other_country in neighbors
			):
				continue

			if (
					other_country.relationships.with_country(target_country)
					.grants_military_access()
			):
				their_relative_strength += relative_strengths[j]

		if (
				my_relative_strength >= their_relative_strength * 1.4
				and target_country in neighbors
		):
			candidate_countries.append(target_country)

	# Determine the country to attack among the candidates
	var country_to_attack: Country = null
	var strength_of_country_to_attack: float = 0.0
	for i in country_list.size():
		var candidate_country: Country = country_list[i]

		if not candidate_country in candidate_countries:
			continue

		var candidate_strength: float = relative_strengths[i]
		if (
				country_to_attack == null
				or candidate_strength < strength_of_country_to_attack
		):
			country_to_attack = candidate_country
			strength_of_country_to_attack = candidate_strength

	#if candidate_countries.size() == 0:
	#	print("No candidate country to attack.")
	#else:
	#	for candidate_country in candidate_countries:
	#		print(
	#				"Candidate country to attack: ",
	#				candidate_country.name_or_default()
	#		)
	#print(
	#		"Not attacking anyone."
	#		if country_to_attack == null else
	#		country_to_attack.name_or_default()
	#		+ " is the weakest neighbor, so I will attack them."
	#)
	#print("-----")

	for country in country_list:
		if country == playing_country:
			continue
		elif country == country_to_attack:
			decisions.dismiss_all_offers_from(country)
			decisions.break_alliance_with(country)
			decisions.declare_war_to(country)
			continue
		decisions.accept_all_offers_from(country)
		decisions.make_peace_with(country)
		decisions.make_alliance_with(country)

	decisions.accept_all_offers()
	return decisions.action_list()
