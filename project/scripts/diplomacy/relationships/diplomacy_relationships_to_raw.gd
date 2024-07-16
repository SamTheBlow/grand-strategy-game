class_name DiplomacyRelationshipsToRaw
## Converts a [DiplomacyRelationships] object into raw data.


func result(diplomacy_relationships: DiplomacyRelationships) -> Array:
	var output_array: Array = []
	for relationship in diplomacy_relationships._list:
		var relationship_dict: Dictionary = _relationship_to_dict(
				relationship,
				diplomacy_relationships._default_relationship_data
		)
		if not relationship_dict.is_empty():
			output_array.append(relationship_dict)
	return output_array


func _relationship_to_dict(
		relationship: DiplomacyRelationship,
		default_relationship_data: Dictionary
) -> Dictionary:
	var output: Dictionary = {
		#"source_country_id": relationship.source_country.id,
		"recipient_country_id": relationship.recipient_country.id,
	}
	
	var base_data: Dictionary = (
			relationship._base_data_no_defaults(default_relationship_data)
	)
	if base_data.is_empty():
		return {}
	
	output["base_data"] = base_data
	return output
