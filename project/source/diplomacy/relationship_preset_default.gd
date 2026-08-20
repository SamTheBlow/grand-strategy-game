class_name RelationshipPresetDefault
extends GameComponent
## Gives some preset to all newly created relationships.

const KEY: String = "relationship_preset_default"

const _PRESET_ID_KEY: String = "preset_id"

var preset_id: int = -1


func _init() -> void:
	priority_index = 0


func register(game: Game) -> void:
	for country in game.countries.list():
		country.relationships.relationship_created.connect(_apply)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if preset_id >= 0:
		output[_PRESET_ID_KEY] = preset_id
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _PRESET_ID_KEY):
		preset_id = ParseUtils.dictionary_int(raw_dict, _PRESET_ID_KEY)
	else:
		preset_id = -1


func _apply(relationship: DiplomacyRelationship) -> void:
	if not relationship.diplomacy_presets.is_id_valid(preset_id):
		return
	relationship._set_preset_id(preset_id)
