class_name AIDecisionUtils
## Utility class. Performs commonly used decisions
## and ensures the decisions are valid.

## Some functions may have no effect if this is kept null.
var game: Game

## Do not directly append actions to this list!
## Use functions like _add_diplomatic_action() instead.
## This is to ensure that the actions in this list are all valid.
var _action_list: Array[Action] = []

var _countries_done_interacting_with: Array[Country] = []


func _init(game_: Game = null) -> void:
	game = game_


## Returns a new copy of the list.
func action_list() -> Array[Action]:
	return _action_list.duplicate()


## Returns an array where each element represents the relative "strength"
## of one country compared to the other countries,
## as determined by an arbitrary algorithm.
## The elements are in the same order as the given game's countries list.
## All the return values are from 0.0 to 1.0,
## 0.0 being the weakest and 1.0 being the strongest.
func relative_strength_of_countries() -> Array[float]:
	var strengths: Array[float] = strength_of_countries()
	var largest_strength: float = 0.0
	for strength in strengths:
		if strength > largest_strength:
			largest_strength = strength

	# Prevent division by zero
	if largest_strength == 0.0:
		largest_strength = 1.0

	var relative_strengths: Array[float] = []
	for strength in strengths:
		relative_strengths.append(strength / largest_strength)
	return relative_strengths


## Returns an array where each element represents the "strength"
## of one country as determined by an arbitrary algorithm.
## The elements are in the same order as the given game's countries list.
func strength_of_countries() -> Array[float]:
	if not game:
		return []

	const SCORE_WEIGHT_MONEY_INCOME: float = 1.0
	const SCORE_WEIGHT_REINFORCEMENTS: float = 100.0
	const SCORE_WEIGHT_EXISTING_ARMIES: float = 10.0

	var strengths: Array[float] = []

	for country in game.countries.list():
		var country_score: float = 0.0
		var provinces_of_country: Array[Province] = (
				game.world.provinces_of_each_country.of_country(country).list
		)

		for province in provinces_of_country:
			var province_score: float = 0.0

			# Score for money income
			match game.rules.province_income_option.selected_value():
				GameRules.ProvinceIncome.RANDOM:
					province_score += (
							SCORE_WEIGHT_MONEY_INCOME
							* game.rules.province_income_random_range.average()
					)
				GameRules.ProvinceIncome.CONSTANT:
					province_score += (
							SCORE_WEIGHT_MONEY_INCOME
							* game.rules.province_income_constant.value
					)
				GameRules.ProvinceIncome.POPULATION:
					province_score += (
							SCORE_WEIGHT_MONEY_INCOME
							* province.population().value
							* game.rules.province_income_per_person.value
					)

			# Score for reinforcements
			if game.rules.reinforcements_enabled:
				match game.rules.reinforcements_option.selected_value():
					GameRules.ReinforcementsOption.RANDOM:
						province_score += (
								SCORE_WEIGHT_REINFORCEMENTS
								* game.rules
								.reinforcements_random_range.average()
						)
					GameRules.ReinforcementsOption.CONSTANT:
						province_score += (
								SCORE_WEIGHT_REINFORCEMENTS
								* game.rules.reinforcements_constant.value
						)
					GameRules.ReinforcementsOption.POPULATION:
						province_score += (
								SCORE_WEIGHT_REINFORCEMENTS
								* province.population().value
								* game.rules.reinforcements_per_person.value
						)

			country_score += province_score

		# Score for existing armies
		var armies_of_country: Array[Army] = (
				game.world.armies_of_each_country.dictionary[country].list
		)
		for army in armies_of_country:
			country_score += (
					SCORE_WEIGHT_EXISTING_ARMIES
					* army.army_size.current_size()
			)

		strengths.append(country_score)

	return strengths


## Call this to stop creating new actions that interact with given country.
## Once called, other functions like make_peace and dismiss_all_offers_from
## will have no effect on given country.
func stop_interacting_with(country: Country) -> void:
	if country in _countries_done_interacting_with:
		return
	_countries_done_interacting_with.append(country)


func make_peace_with(country: Country) -> void:
	if not game:
		return

	# ATTENTION TODO hard coded diplomatic action IDs
	if game.rules.is_diplomacy_presets_enabled():
		_add_action_diplomacy(ActionDiplomacy.new(2, country.id))
	if game.rules.can_ask_to_stop_trespassing.value:
		_add_action_diplomacy(ActionDiplomacy.new(10, country.id))
	if game.rules.can_ask_to_stop_fighting.value:
		_add_action_diplomacy(ActionDiplomacy.new(13, country.id))


func make_alliance_with(country: Country) -> void:
	if not game:
		return

	# TASK hard coded diplomatic action IDs
	if game.rules.is_diplomacy_presets_enabled():
		_add_action_diplomacy(ActionDiplomacy.new(3, country.id))
	if game.rules.can_ask_for_military_access.value:
		_add_action_diplomacy(ActionDiplomacy.new(7, country.id))


func break_alliance_with(country: Country) -> void:
	if not game:
		return

	# TASK hard coded diplomatic action IDs
	if game.rules.is_diplomacy_presets_enabled():
		_add_action_diplomacy(ActionDiplomacy.new(4, country.id))
	if game.rules.can_revoke_military_access.value:
		_add_action_diplomacy(ActionDiplomacy.new(6, country.id))


func declare_war_to(country: Country) -> void:
	if not game:
		return

	# TASK hard coded diplomatic action IDs
	if game.rules.is_diplomacy_presets_enabled():
		_add_action_diplomacy(ActionDiplomacy.new(1, country.id))
	if game.rules.can_enable_trespassing.value:
		_add_action_diplomacy(ActionDiplomacy.new(8, country.id))
	if game.rules.can_enable_fighting.value:
		_add_action_diplomacy(ActionDiplomacy.new(11, country.id))


func accept_offer(game_notification: GameNotification) -> void:
	if not game_notification is GameNotificationOffer:
		return

	# NOTE assumes that the outcome with index 0 is for accepting
	_add_action_notif(ActionHandleNotification.new(game_notification.id, 0))


func dismiss_offer(game_notification: GameNotification) -> void:
	if not game_notification is GameNotificationOffer:
		return

	_add_action_notif(ActionHandleNotification.new(game_notification.id, -1))


func accept_all_offers() -> void:
	if not game:
		return

	var playing_country: Country = game.turn.playing_player().playing_country

	for game_notification in playing_country.notifications.list():
		accept_offer(game_notification)


func accept_all_offers_from(sender_country: Country) -> void:
	if not game:
		return

	var playing_country: Country = game.turn.playing_player().playing_country

	for game_notification in playing_country.notifications.list():
		if game_notification.sender_country() != sender_country:
			continue
		accept_offer(game_notification)


func dismiss_all_offers_from(sender_country: Country) -> void:
	if not game:
		return

	var playing_country: Country = game.turn.playing_player().playing_country

	for game_notification in playing_country.notifications.list():
		if game_notification.sender_country() != sender_country:
			continue
		dismiss_offer(game_notification)


## The choice filter must take an Array[Country] and return a non-null Country.
## The array passed to the choice filter will never be empty.
func fight_a_reachable_country(choice_filter: Callable) -> void:
	if not game:
		return

	var playing_country: Country = game.turn.playing_player().playing_country

	var reachable_countries: Array[Country] = (
			playing_country.reachable_countries(
					game.world.provinces_of_each_country
					.of_country(playing_country),
					game.world.provinces
			)
	)

	if reachable_countries.size() == 0:
		return

	# Don't do it if there's still unclaimed land
	if null in reachable_countries:
		return

	# Check that you're not already fighting at least one neighbor
	var current_reachable_enemies: Array[Country] = []
	for reachable_country in reachable_countries:
		if (
				playing_country.relationships.with_country(reachable_country)
				.is_fighting()
		):
			current_reachable_enemies.append(reachable_country)
	var candidate_countries: Array[Country] = reachable_countries
	if current_reachable_enemies.size() > 0:
		candidate_countries = current_reachable_enemies

	var new_enemy: Country = choice_filter.call(candidate_countries)
	if new_enemy == null:
		push_error(
				"AI tried to fight one of its neighbors, but"
				+ " the choice filter resulted in a null value!"
		)
		return

	dismiss_all_offers_from(new_enemy)
	break_alliance_with(new_enemy)
	declare_war_to(new_enemy)
	stop_interacting_with(new_enemy)


## Attempts to fight the enemies of given country's allies.
func fight_enemies_of_allies(target_country: Country) -> void:
	if not game:
		return

	var playing_country: Country = game.turn.playing_player().playing_country

	if target_country == playing_country:
		return

	# It only matters when you are allies
	var relationship: DiplomacyRelationship = (
			playing_country.relationships.with_country(target_country)
	)
	if not relationship.grants_military_access():
		return

	for other_country in game.countries.list():
		if other_country in [playing_country, target_country]:
			continue

		# It only matters when they are enemies
		var relationship_with_other_country: DiplomacyRelationship = (
				target_country.relationships.with_country(other_country)
		)
		if not relationship_with_other_country.is_fighting():
			continue

		#print(
		#		other_country.country_name, " is the enemy of my friend ",
		#		target_country.country_name, "."
		#)

		# Don't be hostile if the other country is already your ally
		if (
				playing_country.relationships.with_country(other_country)
				.grants_military_access()
		):
			continue

		#print("I am not already friends with them, so, they are my enemy.")
		dismiss_all_offers_from(other_country)
		declare_war_to(other_country)
		stop_interacting_with(other_country)


## Takes an array of countries and returns the weakest one of them.
func weakest_country(countries: Array[Country]) -> Country:
	if not game:
		return countries[0]

	var country_list: Array[Country] = game.countries.list()
	var relative_strengths: Array[float] = relative_strength_of_countries()

	var output_country: Country = null
	var weakest_strength: float = 0.0

	for i in country_list.size():
		var country: Country = country_list[i]

		if not country in countries:
			continue

		var relative_strength: float = relative_strengths[i]

		if (
				output_country == null
				or relative_strength < weakest_strength
		):
			output_country = country
			weakest_strength = relative_strength

	return output_country


## Takes an array of countries and returns one of them at random.
func random_country(countries: Array[Country]) -> Country:
	var random_index: int = game.rng.randi_range(0, countries.size() - 1)
	return countries[random_index]


static func is_peace_offer(game_notification: GameNotification) -> bool:
	if not game_notification is GameNotificationOffer:
		return false
	var offer := game_notification as GameNotificationOffer

	# TODO bad code: private member access
	var recipient_outcome_data: Dictionary = (
			offer._diplomacy_action_definition.their_outcome_data
	)
	return (
			recipient_outcome_data.has("is_fighting")
			and recipient_outcome_data["is_fighting"] == false
	)


static func is_alliance_offer(game_notification: GameNotification) -> bool:
	if not game_notification is GameNotificationOffer:
		return false
	var offer := game_notification as GameNotificationOffer

	# TASK bad code: private member access
	var sender_outcome_data: Dictionary = (
			offer._diplomacy_action_definition.your_outcome_data
	)
	var recipient_outcome_data: Dictionary = (
			offer._diplomacy_action_definition.their_outcome_data
	)
	return (
			sender_outcome_data.has("grants_military_access")
			and sender_outcome_data["grants_military_access"] == true
			and recipient_outcome_data.has("grants_military_access")
			and recipient_outcome_data["grants_military_access"] == true
	)


# TODO more, better validation
func _add_action_diplomacy(action_diplomacy: ActionDiplomacy) -> void:
	if not game:
		return

	if (
			action_diplomacy.target_country(game)
			in _countries_done_interacting_with
	):
		return

	# Avoid making the same action twice
	for other_action in _action_list:
		if action_diplomacy.is_equivalent_to(other_action as ActionDiplomacy):
			return

	# Avoid making an invalid action
	var target_country: Country = action_diplomacy.target_country(game)
	var relationship: DiplomacyRelationship = (
			game.turn.playing_player().playing_country
			.relationships.with_country(target_country)
	)
	var diplomacy_action: DiplomacyAction = (
			action_diplomacy.diplomacy_action(relationship)
	)
	if not diplomacy_action.is_valid(relationship):
		return
	if not diplomacy_action.can_be_performed(game):
		return

	# HACK very ugly
	# Prevent edge case where it declares war first, which is valid,
	# and then it offers alliance which is also valid here
	# but in practice it won't be valid anymore.
	# Also the edge case where it accepts an alliance offer notification
	# and then it tries to declare war which is no longer valid.
	# (I can't think of a simple solution to this, pretty sure we
	# have to simulate a game as the AI makes its actions)
	for other_action in _action_list:
		if (
				other_action is ActionDiplomacy
				and
				(other_action as ActionDiplomacy).target_country(game)
				== action_diplomacy.target_country(game)
		):
			return
		if (
				other_action is ActionHandleNotification
				and
				(other_action as ActionHandleNotification)._outcome_index == 0
				and
				game.turn.playing_player().playing_country.notifications
				.from_id(
						(other_action as ActionHandleNotification)
						._notification_id
				)._sender_country
				== action_diplomacy.target_country(game)
		):
			return

	_action_list.append(action_diplomacy)


# TODO more, better validation
func _add_action_notif(action_notif: ActionHandleNotification) -> void:
	if (
			action_notif.game_notification(game).sender_country()
			in _countries_done_interacting_with
	):
		return

	# Avoid handling the same notification twice
	for action in _action_list:
		var other_action_notif := action as ActionHandleNotification
		if action_notif.handles_the_same_notification_as(other_action_notif):
			return

	_action_list.append(action_notif)
