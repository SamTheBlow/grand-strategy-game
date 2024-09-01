class_name AIPersonalityErratic
extends AIPersonality
## In order of priority:
## - Tends to be at war with at least one reachable nation
## - Tends to accept or ignore offers at random
## - Tends to make offers at random


func actions(game: Game, _player: GamePlayer) -> Array[Action]:
	var playing_country: Country = game.turn.playing_player().playing_country
	#print("--- Erratic ", playing_country.country_name)
	
	var decisions := AIDecisionUtils.new(game)
	
	decisions.fight_a_reachable_country(decisions.random_country)
	
	for game_notification in playing_country.notifications.list():
		# 40% chance to accept
		var is_offer_accepted: bool = (game.rng.randi() % 100) < 40
		#print("Received an offer. Do I accept it: ", is_offer_accepted)
		
		if is_offer_accepted:
			decisions.accept_offer(game_notification)
		else:
			decisions.dismiss_offer(game_notification)
	
	var country_list: Array[Country] = game.countries.list()
	for country in country_list:
		if country == playing_country:
			continue
		
		# 90% chance to do nothing
		var is_ignored: bool = (game.rng.randi() % 100) < 90
		
		if is_ignored:
			continue
		
		#print("Decided to do something about ", country.country_name)
		
		# 70% chance for positive action, 30% chance for negative action
		var is_positive_action: bool = (game.rng.randi() % 100) < 70
		
		if is_positive_action:
			#print("	+ Positive action (offer peace/alliance)")
			decisions.make_peace_with(country)
			decisions.make_alliance_with(country)
		else:
			#print("	- Negative action (break alliance / declare war)")
			decisions.break_alliance_with(country)
			decisions.declare_war_to(country)
	
	#print("---")
	return decisions.action_list()
