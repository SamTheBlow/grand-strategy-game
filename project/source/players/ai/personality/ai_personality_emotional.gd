class_name AIPersonalityEmotional
extends AIPersonality
## In order of priority:
## - Tends to be at war with the enemies of its allies
## - Tends to accept alliance offers
## - Tends to refuse peace offers
## - Tends to offer alliances and declare war at random


func actions(game: Game, _player: GamePlayer) -> Array[Action]:
	var playing_country: Country = game.turn.playing_player().playing_country
	#print("--- Emotional ", playing_country.name_or_default())

	var decisions := AIDecisionUtils.new(game)

	var country_list: Array[Country] = game.countries.list()
	for country in country_list:
		decisions.fight_enemies_of_allies(country)

	for game_notification in playing_country.notifications.list():
		if AIDecisionUtils.is_peace_offer(game_notification):
			decisions.dismiss_offer(game_notification)
			continue

		if AIDecisionUtils.is_alliance_offer(game_notification):
			decisions.accept_offer(game_notification)

	for country in country_list:
		var relationship: DiplomacyRelationship = (
				playing_country.relationships.with_country(country)
		)
		if (
				relationship.grants_military_access()
				or relationship.is_fighting()
		):
			continue

		#print("Candidate for random alliance/war: ", country.name_or_default())

		# 4/5 chance of not doing anything
		var is_event_happening: float = (game.rng.randi() % 5) == 0
		if not is_event_happening:
			continue

		#print("Let's ally them!")

		# 1/5 chance of war instead of alliance
		var is_event_war: bool = (game.rng.randi() % 5) == 0

		if is_event_war:
			#print("...actually, I feel like going to war!")
			decisions.declare_war_to(country)
		else:
			decisions.make_alliance_with(country)

	#print("---")
	return decisions.action_list()
