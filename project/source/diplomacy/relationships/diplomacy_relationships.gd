class_name DiplomacyRelationships
## A list of a country's [DiplomacyRelationship]s.

signal relationship_created(relationship: DiplomacyRelationship)

var _game: Game
var _source_country: Country

## This is a dictionary for performance reasons.
## Do not manipulate the dictionary directly!
var list: Dictionary[Country, DiplomacyRelationship] = {}


func _init(game: Game, country: Country) -> void:
	_game = game
	_source_country = country


## Creates a new relationship with given data and adds it to the list.
## No effect if there already exists a relationship with given country.
func add(
		country: Country,
		relationship_data: Dictionary = {},
		available_actions: Array[DiplomacyAction] = []
) -> void:
	if list.has(country):
		push_error("This country already has relationship data.")
		return

	var relationship := DiplomacyRelationship.new(
			_source_country,
			country,
			_new_default_data(_game.rules).merged(relationship_data, true),
			_new_base_actions(_game.rules)
	)
	relationship.diplomacy_presets = _game.rules.diplomatic_presets
	relationship.diplomacy_actions = _game.rules.diplomatic_actions

	list[country] = relationship
	relationship_created.emit(relationship)
	relationship.initialize_actions(
			_game.turn.current_turn(), available_actions
	)


## Creates a new relationship if there wasn't one before.
## Never returns null.
func with_country(country: Country) -> DiplomacyRelationship:
	if country == null:
		return DiplomacyRelationship.new(_source_country, country)

	if not list.has(country):
		add(country)

	return list[country]


## Returns a new dictionary containing the default data for
## new relationships, depending on the given game rules.
static func _new_default_data(rules: GameRules) -> Dictionary:
	var output: Dictionary = {
		DiplomacyRelationship.GRANTS_MILITARY_ACCESS_KEY:
				rules.grants_military_access_default.value,
		DiplomacyRelationship.IS_TRESPASSING_KEY:
				rules.is_trespassing_default.value,
		DiplomacyRelationship.IS_FIGHTING_KEY:
				rules.is_fighting_default.value,
	}

	if rules.is_diplomacy_presets_enabled():
		# ATTENTION: This assumes that the rule's value is the preset's id.
		output.merge({
			DiplomacyRelationship.PRESET_ID_KEY:
				rules.diplomacy_presets_option.selected_value()
		})

	return output


## Returns a new array containing the ID of each diplomatic action
## that will be available to all countries by default.
static func _new_base_actions(rules: GameRules) -> Array[int]:
	var output: Array[int] = []

	# ATTENTION TODO hard coded values for diplomacy action IDs
	if rules.can_grant_military_access.value:
		output.append(5)
	if rules.can_revoke_military_access.value:
		output.append(6)
	if rules.can_ask_for_military_access.value:
		output.append(7)
	if rules.can_enable_trespassing.value:
		output.append(8)
	if rules.can_disable_trespassing.value:
		output.append(9)
	if rules.can_ask_to_stop_trespassing.value:
		output.append(10)
	if rules.can_enable_fighting.value:
		output.append(11)
	if rules.can_disable_fighting.value:
		output.append(12)
	if rules.can_ask_to_stop_fighting.value:
		output.append(13)

	return output
