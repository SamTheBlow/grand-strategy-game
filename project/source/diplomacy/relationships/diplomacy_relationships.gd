class_name DiplomacyRelationships
## A list of a country's [DiplomacyRelationship]s.

signal relationship_created(relationship: DiplomacyRelationship)

var _game: Game
var _source_country: Country
var _default_relationship_data: Dictionary
var _base_actions: Array[int] = []

## Dictionary[Country, DiplomacyRelationship]
## This is a dictionary for performance reasons.
## Do not manipulate the dictionary directly!
var list: Dictionary = {}


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
	if list.has(country):
		return list[country]
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
		list[country] = relationship
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

	if game_rules.is_diplomacy_presets_enabled():
		# ATTENTION: This assumes that the rule's value is the preset's id.
		default_data[DiplomacyRelationship.PRESET_ID_KEY] = (
				game_rules.diplomacy_presets_option.selected_value()
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
