class_name DiplomacyRelationships
## A list of a country's [DiplomacyRelationship]s.


signal relationship_created(relationship: DiplomacyRelationship)

var _source_country: Country
var _default_relationship_data: Dictionary
var _list: Array[DiplomacyRelationship] = []


func _init(
		country: Country, default_relationship_data: Dictionary = {}
) -> void:
	_source_country = country
	_default_relationship_data = default_relationship_data


## Creates a new relationship if there wasn't one before.
## This never returns null.
func with_country(country: Country) -> DiplomacyRelationship:
	for relationship in _list:
		if relationship.recipient_country == country:
			return relationship
	return _new_relationship(country)


func _new_relationship(country: Country) -> DiplomacyRelationship:
	var default_data: Dictionary = (
			{} if country == null else _default_relationship_data
	)
	
	var relationship := DiplomacyRelationship.new(
			_source_country,
			country,
			default_data
	)
	
	if country != null:
		_list.append(relationship)
		relationship_created.emit(relationship)
	
	return relationship


## Returns a new dictionary containing the default data for
## new relationships, depending on the given game rules.
static func new_default_data(game_rules: GameRules) -> Dictionary:
	var default_data: Dictionary = {
		DiplomacyRelationship.GRANTS_MILITARY_ACCESS_KEY: (
				game_rules.grants_military_access_default.value
		),
		DiplomacyRelationship.IS_TRESPASSING_KEY: (
				game_rules.is_trespassing_default.value
		),
		DiplomacyRelationship.IS_FIGHTING_KEY: (
				game_rules.is_fighting_default.value
		)
	}
	
	# ATTENTION this code relies of the fact that the presets
	# for "allied", "neutral", "at war" have the IDs 1, 2, 3
	match game_rules.diplomacy_presets_option.selected:
		1:
			# Allied
			default_data[DiplomacyRelationship.PRESET_ID_KEY] = 1
		2:
			# Neutral
			default_data[DiplomacyRelationship.PRESET_ID_KEY] = 2
		3:
			# At war
			default_data[DiplomacyRelationship.PRESET_ID_KEY] = 3
		_:
			# Presets are disabled
			pass
	
	return default_data
