class_name RelationshipPresetDefault
extends GameComponent
## Determines the relationship preset to apply to all new relationships.

const KEY: String = "relationship_preset_default"
const TITLE: String = "Relationship Preset Default"
const DESCRIPTION: String = "Determines the relationship preset to apply to all new relationships."
const SETTINGS: Array = [
	{ "property_name": _PRESET_ID_KEY, "text": "Relationship preset", "type": "preset" },
]

const _PRESET_ID_KEY: String = "preset_id"

var preset_id: int = -1


func _init() -> void:
	priority_index = 0


func register(game: Game) -> void:
	for country in game.countries.list:
		_connect_country(country)

	game.countries.added.connect(_connect_country)
	game.countries.removed.connect(_disconnect_country)


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


func _connect_country(country: Country) -> void:
	country.relationships.relationship_created.connect(_apply)


func _disconnect_country(country: Country) -> void:
	country.relationships.relationship_created.disconnect(_apply)


func _apply(relationship: DiplomacyRelationship) -> void:
	if not relationship.diplomacy_presets.is_id_valid(preset_id):
		return
	relationship._set_preset_id(preset_id)
