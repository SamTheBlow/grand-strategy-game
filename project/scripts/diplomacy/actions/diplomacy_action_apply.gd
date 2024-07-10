class_name DiplomacyActionApply
## Class responsible for performing a diplomatic action ([DiplomacyAction]).


func perform_action(
		source_country: Country,
		target_country: Country,
		action: DiplomacyAction
) -> void:
	var relationship: DiplomacyRelationship = (
			source_country.relationships.with_country(target_country)
	)
	var reverse_relationship: DiplomacyRelationship = (
			target_country.relationships.with_country(source_country)
	)
	
	if action.id not in relationship.available_action_ids():
		print_debug(
				"Tried to perform a diplomatic action that isn't available."
		)
		return
	
	# Apply the new data
	relationship._base_data.merge(action.your_outcome_data, true)
	reverse_relationship._base_data.merge(action.their_outcome_data, true)
