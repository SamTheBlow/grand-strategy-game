class_name AIPersonalityInterventionist
extends AIPersonality
## In order of priority:
## - Tends to be at war with at least one reachable nation
## - Tends to declare war on nations that are getting too strong
## - Tends to send & accept peace/alliances with weaker nations
## - Tends to declare war on the enemies of its allies


func actions(game: Game, _player: GamePlayer) -> Array[Action]:
	var playing_country: Country = game.turn.playing_player().playing_country
	#print("--- Interventionist ", playing_country.name_or_default())

	var decisions := AIDecisionUtils.new(game)

	decisions.fight_a_reachable_country(decisions.weakest_country)

	var relative_strengths: Array[float] = (
			decisions.relative_strength_of_countries()
	)
	var sum_of_strengths: float = 0.0
	for strength in relative_strengths:
		sum_of_strengths += strength

	var country_list: Array[Country] = game.countries.list()
	for i in country_list.size():
		var country: Country = country_list[i]

		if country == playing_country:
			continue

		# Befriend weaker countries, fight stronger countries
		var relative_strength: float = relative_strengths[i]
		if relative_strength >= sum_of_strengths * 0.3:
			#print("Very strong country: ", country.name_or_default())
			decisions.dismiss_all_offers_from(country)
			decisions.break_alliance_with(country)
			decisions.declare_war_to(country)
			decisions.stop_interacting_with(country)
		elif relative_strength >= sum_of_strengths * 0.15:
			#print("Strong country: ", country.name_or_default())
			decisions.dismiss_all_offers_from(country)
		elif relative_strength < 0.3:
			#print("Weak country: ", country.name_or_default())
			decisions.accept_all_offers_from(country)
			decisions.make_peace_with(country)
			decisions.make_alliance_with(country)
			decisions.stop_interacting_with(country)

	# It's in a 2nd loop so that it's done after all the other decisions
	for country in country_list:
		decisions.fight_enemies_of_allies(country)

	decisions.accept_all_offers()
	return decisions.action_list()
