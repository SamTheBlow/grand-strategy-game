class_name AIPersonalityGreedy
extends AIPersonality
## In order of priority:
## - Tends to be at war with at least one reachable nation
## - Tends to declare war on weaker reachable nations
## - Tends to seek peace with everyone else
## - Tends to only accept offers from stronger nations
## - Tends to offer alliances with strong nations


func actions(game: Game, _player: GamePlayer) -> Array[Action]:
	var playing_country: Country = game.turn.playing_player().playing_country
	#print("--- Greedy ", playing_country.country_name)

	var decisions := AIDecisionUtils.new(game)

	var relative_strengths: Array[float] = (
			decisions.relative_strength_of_countries()
	)

	# Get sum of strengths
	var sum_of_strengths: float = 0.0
	for strength in relative_strengths:
		sum_of_strengths += strength

	# Get the playing country's strength
	var country_list: Array[Country] = game.countries.list()
	var my_relative_strength: float = 0.0
	for i in country_list.size():
		if country_list[i] == playing_country:
			my_relative_strength = relative_strengths[i]

	var reachable_countries: Array[Country] = (
			playing_country.reachable_countries(
					game.world.provinces_of_each_country
					.of_country(playing_country),
					game.world.provinces
			)
	)

	decisions.fight_a_reachable_country(decisions.weakest_country)

	for i in country_list.size():
		var country: Country = country_list[i]

		if country == playing_country:
			continue

		# Fight weak countries, befriend strong countries
		var relative_strength: float = relative_strengths[i]
		if (
				relative_strength < my_relative_strength * 0.3
				and country in reachable_countries
		):
			#print("Weak country: ", country.country_name)
			decisions.dismiss_all_offers_from(country)
			decisions.break_alliance_with(country)
			decisions.declare_war_to(country)
			decisions.stop_interacting_with(country)
		else:
			decisions.make_peace_with(country)
		if relative_strength >= my_relative_strength:
			#print("Strong country: ", country.country_name)
			decisions.accept_all_offers_from(country)
		elif relative_strength >= sum_of_strengths * 0.3:
			#print("Very strong country: ", country.country_name)
			decisions.accept_all_offers_from(country)
			decisions.make_peace_with(country)
			decisions.make_alliance_with(country)

	#print("---")
	return decisions.action_list()
