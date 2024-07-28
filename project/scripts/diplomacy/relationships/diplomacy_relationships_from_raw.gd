class_name DiplomacyRelationshipsFromRaw
## Converts raw data into a [DiplomacyRelationships] object.


var error: bool = false
var error_message: String = ""
var result: DiplomacyRelationships


func apply(
		data: Variant,
		game: Game,
		country: Country,
		default_data: Dictionary,
		base_actions: Array[int],
) -> void:
	if not data is Array:
		error = true
		error_message = "Data is not an array."
		return
	var data_array := data as Array
	
	var diplomacy_relationships := DiplomacyRelationships.new(
			game, country, default_data, base_actions
	)
	
	for data_element: Variant in data_array:
		if not data_element is Dictionary:
			error = true
			error_message = "Data element is not a dictionary."
			return
		var data_dict := data_element as Dictionary
		
		var relationship: DiplomacyRelationship = (
				_diplomacy_relationship_from_dict(
						game, country, data_dict, default_data, base_actions
				)
		)
		if error:
			return
		diplomacy_relationships._list.append(relationship)
	
	result = diplomacy_relationships


func _diplomacy_relationship_from_dict(
		game: Game,
		country: Country,
		data: Dictionary,
		default_data: Dictionary,
		base_actions: Array[int],
) -> DiplomacyRelationship:
	# TODO mostly copy/paste from [GameNotificationsFromRaw]
	if not (
			data.has("recipient_country_id")
			and typeof(data["recipient_country_id"]) in [TYPE_INT, TYPE_FLOAT]
	):
		error = true
		error_message = (
				"Diplomacy relationship data doesn't contain "
				+ "a recipient country id."
		)
		return null
	var recipient_country_id: int = roundi(data["recipient_country_id"])
	var recipient_country: Country = (
			game.countries.country_from_id(recipient_country_id)
	)
	if recipient_country == null or recipient_country_id < 0:
		error = true
		error_message = (
				"Diplomacy relationship data has an invalid "
				+ "recipient country id. (Id: " + str(recipient_country_id)
				+ ") Perhaps there isn't a country with that id."
		)
		return null
	
	var loaded_relationship_data: Dictionary = {}
	if (data.has("base_data") and data["base_data"] is Dictionary):
		loaded_relationship_data.merge(data["base_data"] as Dictionary)
	
	var actions_already_performed: Array[int] = []
	if (
			data.has("actions_performed_this_turn")
			and data["actions_performed_this_turn"] is Array
	):
		for element: Variant in data["actions_performed_this_turn"] as Array:
			if not typeof(element) in [TYPE_INT, TYPE_FLOAT]:
				continue
			var action_id: int = roundi(element)
			actions_already_performed.append(action_id)
	
	var relationship_data: Dictionary = {}
	relationship_data.merge(default_data)
	relationship_data.merge(loaded_relationship_data, true)
	
	var relationship := DiplomacyRelationship.new(
			country,
			recipient_country,
			game.turn.turn_changed,
			relationship_data.duplicate(),
			base_actions,
	)
	
	relationship.diplomacy_actions = game.rules.diplomatic_actions
	relationship.initialize_actions(
			game.turn.current_turn(), actions_already_performed
	)
	return relationship
