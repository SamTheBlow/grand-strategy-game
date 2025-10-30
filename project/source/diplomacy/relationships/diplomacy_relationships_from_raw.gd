class_name DiplomacyRelationshipsFromRaw
## Converts raw data into a [DiplomacyRelationships].
##
## This operation always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.
##
## See also: [DiplomacyRelationshipsToRaw]

const RECIPIENT_COUNTRY_ID_KEY: String = "recipient_country_id"
const BASE_DATA_KEY: String = "base_data"
const AVAILABLE_ACTIONS_KEY: String = "available_actions"
const TURN_IT_BECAME_AVAILABLE_KEY: String = "turn_it_became_available"
const TURN_IT_WAS_LAST_PERFORMED_KEY: String = "turn_it_was_last_performed"


static func parsed_from(
		raw_data: Variant, game: Game, country: Country
) -> DiplomacyRelationships:
	var output := DiplomacyRelationships.new(game, country)

	if raw_data is not Array:
		return output
	var raw_array: Array = raw_data

	for element_data: Variant in raw_array:
		_parse_diplomacy_relationship(element_data, game, output)

	return output


static func _parse_diplomacy_relationship(
		raw_data: Variant, game: Game, relationships: DiplomacyRelationships
) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# Recipient country (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, RECIPIENT_COUNTRY_ID_KEY):
		return
	var recipient_country: Country = game.countries.country_from_id(
			ParseUtils.dictionary_int(raw_dict, RECIPIENT_COUNTRY_ID_KEY)
	)
	if recipient_country == null:
		return

	# Relationship data (optional)
	var relationship_data: Dictionary = {}
	if ParseUtils.dictionary_has_dictionary(raw_dict, BASE_DATA_KEY):
		relationship_data.merge(raw_dict[BASE_DATA_KEY])

	# Available actions (optional)
	var available_actions: Array[DiplomacyAction] = []
	if ParseUtils.dictionary_has_dictionary(raw_dict, AVAILABLE_ACTIONS_KEY):
		var available_actions_dict: Dictionary = raw_dict[AVAILABLE_ACTIONS_KEY]
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
					available_action_dict, TURN_IT_BECAME_AVAILABLE_KEY
			):
				turn_it_became_available = ParseUtils.dictionary_int(
						available_action_dict,
						TURN_IT_BECAME_AVAILABLE_KEY
				)

			var turn_it_was_last_performed: int = 0
			if ParseUtils.dictionary_has_number(
					available_action_dict, TURN_IT_WAS_LAST_PERFORMED_KEY
			):
				turn_it_was_last_performed = ParseUtils.dictionary_int(
						available_action_dict,
						TURN_IT_WAS_LAST_PERFORMED_KEY
				)

			var new_action := DiplomacyAction.new(
					game.rules.diplomatic_actions.action_from_id(action_id),
					turn_it_became_available,
					turn_it_was_last_performed
			)
			available_actions.append(new_action)

	# Add the new relationship to the list
	relationships.add(recipient_country, relationship_data, available_actions)
