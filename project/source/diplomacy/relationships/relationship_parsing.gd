class_name DiplomacyRelationshipParsing
## Parses raw data from/to [DiplomacyRelationships].

const _RECIPIENT_COUNTRY_ID_KEY: String = "recipient_country_id"
const _BASE_DATA_KEY: String = "base_data"
const _AVAILABLE_ACTIONS_KEY: String = "available_actions"
const _TURN_IT_BECAME_AVAILABLE_KEY: String = "turn_it_became_available"
const _TURN_IT_WAS_LAST_PERFORMED_KEY: String = "turn_it_was_last_performed"


# WARNING: this implementation assumes that the game's countries and
# the data's countries are in the same order.
# If you're going to use this class right after using [CountryParsing],
# then this won't be a problem.
## NOTE: Given game's countries have to be loaded before using this.
##
## Overwrites the relationships property of all countries in given game.
##
## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func load_from_country_data(raw_data: Variant, game: Game) -> void:
	var country_list: Array[Country] = game.countries.list()

	var is_data_valid: bool = true
	var raw_countries_array: Array
	if raw_data is Array:
		raw_countries_array = raw_data
		if raw_countries_array.size() < country_list.size():
			is_data_valid = false
	else:
		is_data_valid = false

	for i in country_list.size():
		var relationships_data: Variant
		if is_data_valid and raw_countries_array[i] is Dictionary:
			var country_dict: Dictionary = raw_countries_array[i]
			relationships_data = (
					country_dict.get(CountryParsing.RELATIONSHIPS_KEY)
			)

		var country: Country = country_list[i]
		country.relationships = from_raw_data(
				relationships_data, game, country
		)


## Always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(
		raw_data: Variant, game: Game, country: Country
) -> DiplomacyRelationships:
	var output := DiplomacyRelationships.new(game, country)

	if raw_data is not Array:
		return output
	var raw_array: Array = raw_data

	for element_data: Variant in raw_array:
		_load_relationship_from_raw_data(element_data, game, output)

	return output


static func _load_relationship_from_raw_data(
		raw_data: Variant, game: Game, relationships: DiplomacyRelationships
) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# Recipient country (mandatory)
	if not ParseUtils.dictionary_has_number(
			raw_dict, _RECIPIENT_COUNTRY_ID_KEY
	):
		return
	var recipient_country: Country = game.countries.country_from_id(
			ParseUtils.dictionary_int(raw_dict, _RECIPIENT_COUNTRY_ID_KEY)
	)
	if recipient_country == null:
		return

	# Relationship data (optional)
	var relationship_data: Dictionary = {}
	if ParseUtils.dictionary_has_dictionary(raw_dict, _BASE_DATA_KEY):
		relationship_data.merge(raw_dict[_BASE_DATA_KEY])

	# Available actions (optional)
	var available_actions: Array[DiplomacyAction] = []
	if ParseUtils.dictionary_has_dictionary(raw_dict, _AVAILABLE_ACTIONS_KEY):
		var available_actions_dict: Dictionary = (
				raw_dict[_AVAILABLE_ACTIONS_KEY]
		)
		for available_action_key: Variant in available_actions_dict:
			if not ParseUtils.is_number(available_action_key):
				continue
			var action_id: int = ParseUtils.number_as_int(available_action_key)

			var available_action_data: Variant = (
					available_actions_dict[available_action_key]
			)
			if available_action_data is not Dictionary:
				continue
			var available_action_dict: Dictionary = available_action_data

			var turn_it_became_available: int = 1
			if ParseUtils.dictionary_has_number(
					available_action_dict, _TURN_IT_BECAME_AVAILABLE_KEY
			):
				turn_it_became_available = ParseUtils.dictionary_int(
						available_action_dict,
						_TURN_IT_BECAME_AVAILABLE_KEY
				)

			var turn_it_was_last_performed: int = 0
			if ParseUtils.dictionary_has_number(
					available_action_dict, _TURN_IT_WAS_LAST_PERFORMED_KEY
			):
				turn_it_was_last_performed = ParseUtils.dictionary_int(
						available_action_dict,
						_TURN_IT_WAS_LAST_PERFORMED_KEY
				)

			var new_action := DiplomacyAction.new(
					game.rules.diplomatic_actions.action_from_id(action_id),
					turn_it_became_available,
					turn_it_was_last_performed
			)
			available_actions.append(new_action)

	# Add the new relationship to the list
	relationships.add(recipient_country, relationship_data, available_actions)


static func to_raw_array(relationships: DiplomacyRelationships) -> Array:
	var default_relationship_data: Dictionary = (
			DiplomacyRelationships._new_default_data(relationships._game.rules)
	)

	var output: Array = []
	for country: Country in relationships.list:
		var relationship_dict: Dictionary = _relationship_to_raw_dict(
				relationships.list[country], default_relationship_data
		)
		if not relationship_dict.is_empty():
			output.append(relationship_dict)
	return output


static func _relationship_to_raw_dict(
		relationship: DiplomacyRelationship,
		default_relationship_data: Dictionary
) -> Dictionary:
	var output: Dictionary = {}

	var base_data: Dictionary = (
			relationship._base_data_without(default_relationship_data)
	)
	if not base_data.is_empty():
		output.merge({ _BASE_DATA_KEY: base_data })

	var available_actions_dict: Dictionary = {}
	for action in relationship.available_actions():
		var action_raw_dict: Dictionary = {}

		if action._turn_it_became_available != 1:
			action_raw_dict.merge({
				_TURN_IT_BECAME_AVAILABLE_KEY:
					action._turn_it_became_available
			})

		if action._turn_it_was_last_performed != 0:
			action_raw_dict.merge({
				_TURN_IT_WAS_LAST_PERFORMED_KEY:
					action._turn_it_was_last_performed
			})

		if not action_raw_dict.is_empty():
			available_actions_dict.merge({ action.id(): action_raw_dict })

	if not available_actions_dict.is_empty():
		output.merge({ _AVAILABLE_ACTIONS_KEY: available_actions_dict })

	if not output.is_empty():
		output.merge({
			_RECIPIENT_COUNTRY_ID_KEY: relationship.recipient_country.id
		})

	return output
