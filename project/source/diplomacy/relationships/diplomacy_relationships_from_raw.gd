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
const PERFORMED_ACTIONS_KEY: String = "actions_performed_this_turn"
const AVAILABLE_ACTIONS_KEY: String = "available_actions"
const TURN_IT_BECAME_AVAILABLE_KEY: String = "turn_it_became_available"


static func parsed_from(
		raw_data: Variant,
		game: Game,
		country: Country,
		default_data: Dictionary,
		base_actions: Array[int],
) -> DiplomacyRelationships:
	var diplomacy_relationships := DiplomacyRelationships.new(
			game, country, default_data, base_actions
	)

	if raw_data is not Array:
		return diplomacy_relationships
	var raw_array: Array = raw_data

	for element_data: Variant in raw_array:
		var relationship: DiplomacyRelationship = _parsed_diplomacy_relationship(
				element_data, game, country, default_data, base_actions
		)
		if relationship == null:
			continue

		diplomacy_relationships.list[relationship.recipient_country] = (
				relationship
		)

	return diplomacy_relationships


## This operation may fail, in which case it returns null.
static func _parsed_diplomacy_relationship(
		raw_data: Variant,
		game: Game,
		country: Country,
		default_data: Dictionary,
		base_actions: Array[int],
) -> DiplomacyRelationship:
	# Fails if the raw data isn't a dictionary
	if raw_data is not Dictionary:
		return null
	var raw_dict: Dictionary = raw_data

	# Fails if there is no recipient country id, or if it's not a number
	if not ParseUtils.dictionary_has_number(raw_dict, RECIPIENT_COUNTRY_ID_KEY):
		return null
	var recipient_country_id: int = (
			ParseUtils.dictionary_int(raw_dict, RECIPIENT_COUNTRY_ID_KEY)
	)

	# Fails if the recipient country id doesn't refer to a valid country
	var recipient_country: Country = (
			game.countries.country_from_id(recipient_country_id)
	)
	if recipient_country == null:
		return null

	var loaded_relationship_data: Dictionary = {}
	if ParseUtils.dictionary_has_dictionary(raw_dict, BASE_DATA_KEY):
		loaded_relationship_data.merge(raw_dict[BASE_DATA_KEY])

	# Backwards compatibility: 4.1
	# A list of already performed actions is saved and handled separately.
	var actions_already_performed: Array[int] = []
	if ParseUtils.dictionary_has_array(raw_dict, PERFORMED_ACTIONS_KEY):
		for element: Variant in raw_dict[PERFORMED_ACTIONS_KEY] as Array:
			if not ParseUtils.is_number(element):
				continue
			var action_id: int = ParseUtils.number_as_int(element)
			actions_already_performed.append(action_id)

	var available_actions: Array[DiplomacyAction] = []
	if ParseUtils.dictionary_has_dictionary(raw_dict, AVAILABLE_ACTIONS_KEY):
		var available_actions_dict: Dictionary = raw_dict[AVAILABLE_ACTIONS_KEY]
		for available_action_key: Variant in available_actions_dict.keys():
			if not ParseUtils.is_number(available_action_key):
				continue
			var action_id: int = ParseUtils.number_as_int(available_action_key)

			var available_action_data: Variant = (
					available_actions_dict[available_action_key]
			)
			if available_action_data is not Dictionary:
				continue

			var available_action_dict: Dictionary = available_action_data
			if not ParseUtils.dictionary_has_number(
					available_action_dict, TURN_IT_BECAME_AVAILABLE_KEY
			):
				continue

			var new_action := DiplomacyAction.new(
					game.rules.diplomatic_actions.action_from_id(action_id),
					game.turn.turn_changed,
					ParseUtils.dictionary_int(
							available_action_dict,
							TURN_IT_BECAME_AVAILABLE_KEY
					),
					actions_already_performed.has(action_id)
			)
			available_actions.append(new_action)

	var relationship_data: Dictionary = {}
	relationship_data.merge(default_data)
	relationship_data.merge(loaded_relationship_data, true)

	var relationship := DiplomacyRelationship.new(
			country,
			recipient_country,
			game.turn.turn_changed,
			relationship_data,
			base_actions,
	)

	relationship.diplomacy_presets = game.rules.diplomatic_presets
	relationship.diplomacy_actions = game.rules.diplomatic_actions
	relationship.initialize_actions(
			game.turn.current_turn(),
			actions_already_performed,
			available_actions
	)
	return relationship
