class_name DiplomacyRelationships
## A list of a country's [DiplomacyRelationship]s.


signal relationship_created(relationship: DiplomacyRelationship)

var _game: Game
var _source_country: Country
var _default_relationship_data: Dictionary
var _base_actions: Array[int] = []

var _list: Array[DiplomacyRelationship] = []


func _init(
		game: Game,
		country: Country,
		default_relationship_data: Dictionary = {},
		base_actions: Array[int] = [],
) -> void:
	_game = game
	_source_country = country
	_default_relationship_data = default_relationship_data
	_base_actions = base_actions


## Creates a new relationship if there wasn't one before.
## This never returns null.
func with_country(country: Country) -> DiplomacyRelationship:
	for relationship in _list:
		if relationship.recipient_country == country:
			return relationship
	return _new_relationship(country)


func _new_relationship(country: Country) -> DiplomacyRelationship:
	var default_data: Dictionary = {}
	var base_actions: Array[int] = []
	if country != null:
		default_data = _default_relationship_data
		base_actions = _base_actions
	
	var relationship := DiplomacyRelationship.new(
			_source_country,
			country,
			_game.turn.turn_changed,
			default_data.duplicate(),
			base_actions,
	)
	
	# TODO this is ugly
	if default_data.has("diplomacy_presets"):
		relationship.diplomacy_presets = default_data["diplomacy_presets"]
	if default_data.has("diplomacy_actions"):
		relationship.diplomacy_actions = default_data["diplomacy_actions"]
	
	if country != null:
		_list.append(relationship)
		relationship_created.emit(relationship)
		
		relationship.initialize_actions(_game.turn.current_turn())
	
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
		),
		"diplomacy_presets": game_rules.diplomatic_presets,
		"diplomacy_actions": game_rules.diplomatic_actions,
	}
	
	# ATTENTION: This assumes that the rule's value is the preset's id.
	var diplomatic_presets_option: int = (
			game_rules.diplomacy_presets_option.selected
	)
	if diplomatic_presets_option != 0:
		default_data[DiplomacyRelationship.PRESET_ID_KEY] = (
				diplomatic_presets_option
		)
	
	return default_data


## Returns a new array containing the ID of each diplomatic action
## that will be available to all countries by default.
static func new_base_actions(game_rules: GameRules) -> Array[int]:
	var output: Array[int] = []
	
	# ATTENTION TODO hard coded values for diplomacy action IDs
	if game_rules.can_grant_military_access.value:
		output.append(5)
	if game_rules.can_revoke_military_access.value:
		output.append(6)
	if game_rules.can_ask_for_military_access.value:
		output.append(7)
	if game_rules.can_enable_trespassing.value:
		output.append(8)
	if game_rules.can_disable_trespassing.value:
		output.append(9)
	if game_rules.can_ask_to_stop_trespassing.value:
		output.append(10)
	if game_rules.can_enable_fighting.value:
		output.append(11)
	if game_rules.can_disable_fighting.value:
		output.append(12)
	if game_rules.can_ask_to_stop_fighting.value:
		output.append(13)
	
	return output
