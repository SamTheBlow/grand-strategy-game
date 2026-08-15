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

	var settings: DiplomacySettings = _settings()
	var relationship := DiplomacyRelationship.new(
			_source_country,
			country,
			_new_default_data(settings).merged(relationship_data, true),
			_new_base_actions(settings)
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


## Clears all data in this instance.
func clear() -> void:
	list.clear()


## May return null.
func _settings() -> DiplomacySettings:
	return _game.components.get(DiplomacySettings.KEY) as DiplomacySettings


## Returns a new dictionary containing the default data for
## new relationships, according to given settings.
static func _new_default_data(settings: DiplomacySettings) -> Dictionary:
	var grants_access: bool = false
	var is_trespassing: bool = false
	var is_fighting: bool = false
	var preset_id: int = DiplomacyRelationship.PRESET_ID_DEFAULT
	if settings != null:
		grants_access = settings.grants_military_access_default
		is_trespassing = settings.is_trespassing_default
		is_fighting = settings.is_fighting_default
		if settings.is_presets_enabled():
			preset_id = settings.preset_option

	return {
		DiplomacyRelationship.GRANTS_MILITARY_ACCESS_KEY: grants_access,
		DiplomacyRelationship.IS_TRESPASSING_KEY: is_trespassing,
		DiplomacyRelationship.IS_FIGHTING_KEY: is_fighting,
		DiplomacyRelationship.PRESET_ID_KEY: preset_id,
	}


## Returns a new array containing the ID of each diplomatic action
## that will be available to all countries by default.
static func _new_base_actions(settings: DiplomacySettings) -> Array[int]:
	var output: Array[int] = []
	if settings == null:
		return output

	# ATTENTION TODO hard coded values for diplomacy action IDs
	if settings.can_grant_military_access:
		output.append(5)
	if settings.can_revoke_military_access:
		output.append(6)
	if settings.can_ask_for_military_access:
		output.append(7)
	if settings.can_enable_trespassing:
		output.append(8)
	if settings.can_disable_trespassing:
		output.append(9)
	if settings.can_ask_to_stop_trespassing:
		output.append(10)
	if settings.can_enable_fighting:
		output.append(11)
	if settings.can_disable_fighting:
		output.append(12)
	if settings.can_ask_to_stop_fighting:
		output.append(13)

	return output
