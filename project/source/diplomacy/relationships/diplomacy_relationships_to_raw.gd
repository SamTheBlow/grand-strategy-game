class_name DiplomacyRelationshipsToRaw
## Converts a [DiplomacyRelationships] object into raw data.
##
## See also: [DiplomacyRelationshipsFromRaw]


static func result(diplomacy_relationships: DiplomacyRelationships) -> Array:
	var output_array: Array = []
	for country: Country in diplomacy_relationships.list:
		var relationship_dict: Dictionary = _relationship_to_dict(
				diplomacy_relationships.list[country],
				diplomacy_relationships._default_relationship_data
		)
		if not relationship_dict.is_empty():
			output_array.append(relationship_dict)
	return output_array


static func _relationship_to_dict(
		relationship: DiplomacyRelationship,
		default_relationship_data: Dictionary
) -> Dictionary:
	var output: Dictionary = {}

	var base_data: Dictionary = (
			relationship._base_data_no_defaults(default_relationship_data)
	)
	if not base_data.is_empty():
		output.merge({
			DiplomacyRelationshipsFromRaw.BASE_DATA_KEY: base_data
		})

	var actions_performed_this_turn: Array[int] = []
	for action in relationship.available_actions():
		if action.was_performed_this_turn():
			actions_performed_this_turn.append(action.id())
	if not actions_performed_this_turn.is_empty():
		output.merge({
			DiplomacyRelationshipsFromRaw.PERFORMED_ACTIONS_KEY:
				actions_performed_this_turn,
		})

	var available_actions_dict: Dictionary = {}
	for action in relationship.available_actions():
		available_actions_dict[action.id()] = {
			DiplomacyRelationshipsFromRaw.TURN_IT_BECAME_AVAILABLE_KEY:
				action._turn_it_became_available,
		}
	if not available_actions_dict.is_empty():
		output.merge({
			DiplomacyRelationshipsFromRaw.AVAILABLE_ACTIONS_KEY:
				available_actions_dict,
		})

	if not output.is_empty():
		output.merge({
			DiplomacyRelationshipsFromRaw.RECIPIENT_COUNTRY_ID_KEY:
				relationship.recipient_country.id,
		})

	return output
