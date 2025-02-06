class_name PopulatedSaveFile
## Populates given game file (in JSON format)
## according to given generation settings (see [GameRules]).

## The result is a new game file in JSON format.
var result: Variant

var error: bool = false
var error_message: String = ""


# NOTE: In the future, the generation settings will probably its own thing
# not included in the [GameRules]. That's why we intentionally
# don't just take the game rules directly from the given JSON data.
## Note: this does not do anything to the given inputs.
func apply(input_json: Variant, generation_settings: GameRules) -> void:
	result = null
	error = false
	error_message = ""

	if input_json is not Dictionary:
		error = true
		error_message = "Input JSON is not a Dictionary"
		return
	var input_json_dict: Dictionary = input_json as Dictionary

	var output_json: Dictionary = {}

	# Version
	if not (
			input_json_dict.has("version")
			and input_json_dict["version"] is String
	):
		error = true
		error_message = "Input JSON does not contain valid 'version'"
		return
	output_json["version"] = input_json_dict["version"]

	# Rules
	# For now, let's just replace them with the given game rules.
	# This might be a bad idea but right now I can't think of a reason why.
	output_json["rules"] = RulesToRawDict.parsed_from(generation_settings)

	# Players and countries
	var players_data: Array = []
	if ParseUtils.dictionary_has_array(input_json_dict, "players"):
		players_data = input_json_dict["players"].duplicate()

	if not ParseUtils.dictionary_has_array(input_json_dict, "countries"):
		error = true
		error_message = "Input JSON does not contain valid 'countries'"
		return
	var countries_data: Array = input_json_dict["countries"].duplicate()

	_add_players(players_data, countries_data)
	_randomly_assign_players_to_countries(players_data, countries_data)
	_populate_countries_data(countries_data, generation_settings)
	_populate_players_data(players_data, generation_settings)
	output_json["players"] = players_data
	output_json["countries"] = countries_data

	# World
	if not ParseUtils.dictionary_has_dictionary(input_json_dict, "world"):
		error = true
		error_message = "Input JSON does not contain valid 'world'"
		return
	var world_data: Dictionary = input_json_dict["world"].duplicate()

	# Provinces
	if not ParseUtils.dictionary_has_array(world_data, "provinces"):
		error = true
		error_message = "Input world data does not contain valid 'provinces'"
		return
	var provinces_data: Array = world_data["provinces"]
	for i in provinces_data.size():
		if provinces_data[i] is not Dictionary:
			continue
		var province_data: Dictionary = provinces_data[i]

		# Determine if this is a "starting province"
		var owner_country_id: int = -1
		if ParseUtils.dictionary_has_number(province_data, "owner_country_id"):
			owner_country_id = ParseUtils.dictionary_int(
					province_data, "owner_country_id"
			)
		var is_starting_province: bool = owner_country_id >= 0

		# Set money income according to game rules
		match generation_settings.province_income_option.selected_value():
			GameRules.ProvinceIncome.RANDOM:
				province_data["income_money"] = randi_range(
						generation_settings.province_income_random_min.value,
						generation_settings.province_income_random_max.value
				)
			GameRules.ProvinceIncome.CONSTANT:
				province_data["income_money"] = (
						generation_settings.province_income_constant.value
				)
			GameRules.ProvinceIncome.POPULATION:
				pass

		# Randomize population size
		var exponential_rng: float = randf() ** 2.0
		var population_size: int = floori(exponential_rng * 1000.0)
		if is_starting_province:
			population_size += (
					generation_settings.extra_starting_population.value
			)
		province_data["population"] = {
			"size": population_size,
		}

		# Add a fortress, if applicable
		if (
				generation_settings.start_with_fortress.value
				and is_starting_province
		):
			_add_fortress(province_data)

	# Armies
	_add_starting_armies(world_data)

	output_json["world"] = world_data

	result = output_json


## Add new players to match the number of countries in the game.
## This is so that each country starts with an AI.
func _add_players(players_data: Array, countries_data: Array) -> void:
	# We first need to note down which player ids are already taken,
	# and which country ids already have a player assigned
	var used_player_ids: Array[int] = []
	var assigned_country_ids: Array[int] = []
	for player_data: Variant in players_data:
		if player_data is not Dictionary:
			continue
		var player_dict := player_data as Dictionary

		if not ParseUtils.dictionary_has_number(player_dict, "id"):
			continue
		var player_id: int = ParseUtils.dictionary_int(player_dict, "id")

		# Add the assigned country to the list
		if ParseUtils.dictionary_has_number(player_dict, "owner_country_id"):
			var owner_country_id: int = (
					ParseUtils.dictionary_int(player_dict, "owner_country_id")
			)
			if owner_country_id not in assigned_country_ids:
				assigned_country_ids.append(owner_country_id)

		if player_id in used_player_ids:
			# TODO Btw if this happens then the entire save file is just invalid
			# But for now let's just pretend it's ok
			continue
		used_player_ids.append(player_id)

	# For each country, check if it has a player assigned to it.
	# If not, create a new player for this country.
	var new_unique_player_id: int = 0
	for element: Variant in countries_data:
		if element is not Dictionary:
			continue
		var country_data := element as Dictionary

		# Get the country's id
		if not ParseUtils.dictionary_has_number(country_data, "id"):
			continue
		var country_id: int = ParseUtils.dictionary_int(country_data, "id")

		# Check if there's a player assigned to this country
		if country_id in assigned_country_ids:
			continue

		# Get a new unique id for the new player
		while new_unique_player_id in used_player_ids:
			new_unique_player_id += 1

		# Create and add the new player
		var player_data: Dictionary = {}
		player_data["id"] = new_unique_player_id
		player_data["is_human"] = false
		player_data["playing_country_id"] = country_id
		used_player_ids.append(new_unique_player_id)
		players_data.append(player_data)


## If a player is already assigned to a valid country,
## it stays assigned to that country.
## Otherwise, assigns it a random unassigned country.
## If all countries are already assigned, then that player
## is considered a spectator and no country is assigned to that player.
func _randomly_assign_players_to_countries(
		players_data: Array, countries_data: Array
) -> void:
	# Create list of all the country ids
	var country_ids: Array = []
	for i in countries_data.size():
		# WARNING assumes the countries data is valid (a dictionary with "id")
		var country_id: int = countries_data[i]["id"]

		if country_id not in country_ids:
			country_ids.append(country_id)

	# Create list of country ids in random order
	var random_country_id_list: Array = country_ids.duplicate()
	random_country_id_list.shuffle()

	# Create list of players that need to be assigned a country id
	var players_to_assign: Array = range(players_data.size())

	# Remove already assigned country ids from the list of random country ids;
	# Remove already assigned players from the list of players to assign;
	for i in players_data.size():
		# WARNING assumes the player data is a dictionary
		var player_data: Dictionary = players_data[i]

		if not ParseUtils.dictionary_has_number(
				player_data, "playing_country_id"
		):
			continue

		var playing_country_id: int = (
				ParseUtils.dictionary_int(player_data, "playing_country_id")
		)

		if playing_country_id not in country_ids:
			continue

		# This player already has a valid country id assigned to it.
		# Let's remove the country and the player from the lists.
		if playing_country_id in random_country_id_list:
			random_country_id_list.erase(playing_country_id)
		players_to_assign.erase(i)

	# Assign players
	for player_index: int in players_to_assign:
		# WARNING assumes the player data is a dictionary
		var player_data: Dictionary = players_data[player_index]

		if random_country_id_list.size() == 0:
			# Spectator
			player_data["playing_country_id"] = -1
			continue

		player_data["playing_country_id"] = random_country_id_list.pop_back()


func _populate_countries_data(countries_data: Array, rules: GameRules) -> void:
	for country_data: Variant in countries_data:
		if not country_data is Dictionary:
			continue
		var country_dict := country_data as Dictionary
		country_dict["money"] = rules.starting_money.value

	_randomize_relationship_presets(countries_data, rules)


## Randomizes the relationship presets of all countries,
## if the [GameRules] say to do it.
## Existing relationship preset data is ignored and overwritten.
func _randomize_relationship_presets(
		countries_data: Array, rules: GameRules
) -> void:
	if not (
			rules.is_diplomacy_presets_enabled()
			and rules.starts_with_random_relationship_preset.value
	):
		return

	var number_of_countries: int = countries_data.size()

	# Create and populate array with random values
	var random_relationship_preset: Array[Dictionary] = []
	for i in number_of_countries:
		random_relationship_preset.append({})
	for i in number_of_countries:
		for j in range(i + 1, number_of_countries):
			var random_preset: int = 1 + randi() % 3
			random_relationship_preset[i][j] = random_preset
			random_relationship_preset[j][i] = random_preset

	# Apply random values to country data
	for i in number_of_countries:
		# WARNING assumes the country data is a dictionary
		countries_data[i]["relationships"] = []
		for j in random_relationship_preset.size():
			if i == j:
				continue

			countries_data[i]["relationships"].append({
				"recipient_country_id": j,
				"base_data": {
					"preset_id": random_relationship_preset[i][j]
				},
			})


## Takes an [Array] of raw [Dictionary] representing [AIPlayer]s
## and randomizes its data according to the game rules, when applicable.
func _populate_players_data(players_data: Array, rules: GameRules) -> void:
	for element: Variant in players_data:
		if not element is Dictionary:
			continue
		var dictionary := element as Dictionary
		_apply_random_ai_type(dictionary, rules)
		_apply_random_ai_personality_type(dictionary, rules)


## Takes a raw [Dictionary] representing an [AIPlayer]
## and randomizes its AI type.
func _apply_random_ai_type(dictionary: Dictionary, rules: GameRules) -> void:
	# 4.0 Backwards compatibility:
	# When the save data doesn't contain the AI type,
	# it must be assumed to be 0.

	if not rules.start_with_random_ai_type.value:
		var default_ai_type: int = rules.default_ai_type.value
		if default_ai_type != 0:
			dictionary.merge({"ai_type": default_ai_type}, true)
		return

	var possible_ai_types: Array = PlayerAI.Type.values()
	possible_ai_types.erase(PlayerAI.Type.NONE)
	if possible_ai_types.size() == 0:
		push_error("There is no valid AI type to randomly assign!")
		return

	var random_index: int = randi() % possible_ai_types.size()
	var random_ai_type: int = possible_ai_types[random_index]

	dictionary.merge({"ai_type": random_ai_type}, true)


## Takes a raw [Dictionary] representing an [AIPlayer]
## and randomizes its AI personality type.
func _apply_random_ai_personality_type(
		dictionary: Dictionary, rules: GameRules
) -> void:
	if not rules.start_with_random_ai_personality.value:
		return

	var possible_personality_types: Array[int] = AIPersonality.type_values()
	possible_personality_types.erase(AIPersonality.Type.NONE)
	possible_personality_types.erase(AIPersonality.Type.ACCEPTS_EVERYTHING)
	if possible_personality_types.size() == 0:
		push_error("There is no valid personality type to randomly assign!")
		return

	var random_index: int = randi() % possible_personality_types.size()
	var random_personality_type: int = possible_personality_types[random_index]

	if (
			random_personality_type
			== rules.default_ai_personality_option.selected_value()
	):
		return

	dictionary.merge({"ai_personality_type": random_personality_type}, true)


## Adds an army of given size in one province of each country.
func _add_starting_armies(
		world_data: Dictionary, army_size: int = 1000
) -> void:
	var army_array: Array = []

	var already_supplied_country_ids: Array[int] = []
	var provinces_array := (
			world_data[WorldFromRaw.WORLD_PROVINCES_KEY] as Array
	)
	for province_data: Variant in provinces_array:
		var province_dict := province_data as Dictionary
		if not ParseUtils.dictionary_has_number(
				province_dict, ProvincesFromRaw.PROVINCE_OWNER_ID_KEY
		):
			continue
		var owner_id: int = ParseUtils.dictionary_int(
				province_dict, ProvincesFromRaw.PROVINCE_OWNER_ID_KEY
		)
		if owner_id == -1 or owner_id in already_supplied_country_ids:
			continue

		var army_id: int = already_supplied_country_ids.size() + 1
		var province_id: int = ParseUtils.dictionary_int(
				province_dict, ProvincesFromRaw.PROVINCE_ID_KEY
		)

		army_array.append({
			ArmiesFromRaw.ARMY_ID_KEY: army_id,
			ArmiesFromRaw.ARMY_SIZE_KEY: army_size,
			ArmiesFromRaw.ARMY_OWNER_ID_KEY: owner_id,
			ArmiesFromRaw.ARMY_PROVINCE_ID_KEY: province_id,
		})
		already_supplied_country_ids.append(owner_id)

	world_data.merge({ WorldFromRaw.WORLD_ARMIES_KEY: army_array }, true)


func _add_fortress(province_data: Dictionary) -> void:
	if not ParseUtils.dictionary_has_array(province_data, "buildings"):
		province_data["buildings"] = []

	var buildings_data: Array = province_data["buildings"]

	# Check if there's already a fortress. We don't want to add a 2nd one
	for building_data: Variant in buildings_data:
		if building_data is not Dictionary:
			continue
		var building_dict := building_data as Dictionary
		if building_dict.has("type") and building_dict["type"] == "fortress":
			# There's already a fortress in this province
			return

	buildings_data.append({"type": "fortress"})
