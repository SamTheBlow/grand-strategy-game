class_name PopulatedSaveFile
## Populates given [Game] depending on its [GameRules].
## Meant to be applied to new game instances.
##
## This operation always succeeds.


static func apply(game: Game) -> void:
	# Players and countries
	_add_players(game)
	_randomly_assign_players_to_countries(game)
	_populate_countries(game)
	_populate_players(game)

	# Provinces
	for province in game.world.provinces.list():
		# Determine if this is a "starting province"
		var is_starting_province: bool = province.owner_country != null

		# Set money income according to game rules
		match game.rules.province_income_option.selected_value():
			GameRules.ProvinceIncome.RANDOM:
				province._income_money = IncomeMoneyConstant.new(
						game.rng.randi_range(
								game.rules.province_income_random_min.value,
								game.rules.province_income_random_max.value
						)
				)
			GameRules.ProvinceIncome.CONSTANT:
				province._income_money = IncomeMoneyConstant.new(
						game.rules.province_income_constant.value
				)
			GameRules.ProvinceIncome.POPULATION:
				province._income_money = IncomeMoneyPerPopulation.new(
						province.population,
						game.rules.province_income_per_person.value
				)

		# Randomize population size
		var exponential_rng: float = game.rng.randf() ** 2.0
		var population_size: int = floori(exponential_rng * 1000.0)
		if is_starting_province:
			population_size += game.rules.extra_starting_population.value
		province.population.population_size = population_size

		# Add a fortress, if applicable
		if (
				game.rules.start_with_fortress.value and is_starting_province
				and
				province.buildings.number_of_type(Building.Type.FORTRESS) == 0
		):
			province.buildings.add(Fortress.new_fortress(game, province))

	# Armies
	_add_starting_armies(game)


## Add new players so that each country starts with an AI.
static func _add_players(game: Game) -> void:
	# Find which countries already have a player assigned
	var assigned_countries: Array[Country] = []
	for game_player in game.game_players.list():
		if (
				game_player.playing_country != null
				and (game_player.playing_country not in assigned_countries)
		):
			assigned_countries.append(game_player.playing_country)

	# Create a new player for each unassigned country
	for country in game.countries.list():
		if country in assigned_countries:
			continue

		var new_player := GamePlayer.new()
		new_player.playing_country = country
		new_player.player_ai = (
				PlayerAI.from_type(game.rules.default_ai_type.value)
		)
		new_player.player_ai.personality = AIPersonality.from_type(
				game.rules.default_ai_personality_option.selected_value()
		)
		game.game_players.add_player(new_player)


## If a player is already assigned to a valid country,
## it stays assigned to that country.
## Otherwise, assigns it a random unassigned country.
## If all countries are already assigned,
## then the remaining players are not assigned a country.
static func _randomly_assign_players_to_countries(game: Game) -> void:
	# Randomly shuffled list of countries
	var country_list: Array[Country] = game.countries.list()
	country_list.shuffle()

	# List of players that need to be assigned a country
	var players_to_assign: Array[GamePlayer] = game.game_players.list()

	# Remove already assigned countries from the list of countries
	# Remove already assigned players from the list of players
	for game_player in game.game_players.list():
		if game_player.playing_country == null:
			continue

		if game_player.playing_country in country_list:
			country_list.erase(game_player.playing_country)
		players_to_assign.erase(game_player)

	# Assign players
	for game_player in players_to_assign:
		if country_list.is_empty():
			return
		game_player.playing_country = country_list.pop_back()


static func _populate_countries(game: Game) -> void:
	var is_relationship_preset_randomized: bool = (
			game.rules.is_diplomacy_presets_enabled()
			and game.rules.starts_with_random_relationship_preset.value
	)

	var countries: Array[Country] = game.countries.list()
	for i in countries.size():
		# Starting money
		countries[i].money = game.rules.starting_money.value

		# Relationships
		if is_relationship_preset_randomized:
			_randomize_relationship_presets(i, game)


## Ignores and overwrites existing data.
## "i" is the index of the country to randomize. This function is optimized
## such that we only need to iterate through the countries once.
static func _randomize_relationship_presets(i: int, game: Game) -> void:
	var countries: Array[Country] = game.countries.list()
	for j in range(i + 1, countries.size()):
		var relationship: DiplomacyRelationship = (
				countries[i].relationships.with_country(countries[j])
		)
		var reverse_relationship: DiplomacyRelationship = (
				countries[j].relationships.with_country(countries[i])
		)
		var random_preset_id: int = 1 + game.rng.randi() % 3
		relationship._set_preset_id(random_preset_id)
		reverse_relationship._set_preset_id(random_preset_id)


## Randomizes the AI of each player depending on the game rules.
static func _populate_players(game: Game) -> void:
	for game_player in game.game_players.list():
		_apply_random_ai_type(game_player, game)
		_apply_random_ai_personality_type(game_player, game)


## Only overwrites the AI type when all the conditions are met.
static func _apply_random_ai_type(player: GamePlayer, game: Game) -> void:
	if not game.rules.start_with_random_ai_type.value:
		return

	var possible_ai_types: Array = PlayerAI.Type.values()
	possible_ai_types.erase(PlayerAI.Type.NONE)
	if possible_ai_types.size() == 0:
		push_error("There is no valid AI type to randomly assign!")
		return

	var random_index: int = game.rng.randi() % possible_ai_types.size()
	var random_ai_type: int = possible_ai_types[random_index]
	player.player_ai = PlayerAI.from_type(random_ai_type)


## Only overwrites the AI personality when all the conditions are met.
static func _apply_random_ai_personality_type(
		player: GamePlayer, game: Game
) -> void:
	if not game.rules.start_with_random_ai_personality.value:
		return

	var possible_personality_types: Array[int] = AIPersonality.type_values()
	possible_personality_types.erase(AIPersonality.Type.NONE)
	possible_personality_types.erase(AIPersonality.Type.ACCEPTS_EVERYTHING)
	if possible_personality_types.size() == 0:
		push_error("There is no valid personality type to randomly assign!")
		return

	var random_index: int = game.rng.randi() % possible_personality_types.size()
	var random_personality_type: int = possible_personality_types[random_index]
	player.player_ai.personality = (
			AIPersonality.from_type(random_personality_type)
	)


## Adds armies such that it only gives one army to each country.
static func _add_starting_armies(game: Game) -> void:
	var already_supplied_countries: Array[Country] = []
	for province in game.world.provinces.list():
		if (
				province.owner_country == null or
				province.owner_country in already_supplied_countries
		):
			continue

		Army.quick_setup(
				game,
				# TODO create a rule for this
				1000,
				province.owner_country,
				province
		)
		already_supplied_countries.append(province.owner_country)
