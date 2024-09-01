class_name DiplomacyRelationship
## Represents how one country behaves in relation with given country.
# TODO the setup is confusing. document and simplify it
# (this class is ugly and bloated)


signal preset_changed(this: DiplomacyRelationship)
signal military_access_changed(this: DiplomacyRelationship)
signal trespassing_changed(this: DiplomacyRelationship)
signal fighting_changed(this: DiplomacyRelationship)
signal available_actions_changed(this: DiplomacyRelationship)

const PRESET_ID_KEY: String = "preset_id"
const PRESET_ID_DEFAULT: int = -1

const GRANTS_MILITARY_ACCESS_KEY: String = "grants_military_access"
const GRANTS_MILITARY_ACCESS_DEFAULT: bool = false

const IS_TRESPASSING_KEY: String = "is_trespassing"
const IS_TRESPASSING_DEFAULT: bool = true

const IS_FIGHTING_KEY: String = "is_fighting"
const IS_FIGHTING_DEFAULT: bool = true

var source_country: Country
var recipient_country: Country

## The game's registered diplomacy presets.
## Defines the presets that may be used in this relationship.
var diplomacy_presets := DiplomacyPresets.new()

## The game's registered diplomacy actions.
## Defines the actions that may be used in this relationship.
var diplomacy_actions := DiplomacyActionDefinitions.new()

## Information about the relationship.
## It's possible to add/change/remove data using diplomatic actions.
var _base_data: Dictionary = {}:
	set(value):
		_base_data = value
		# Ensure the preset id is an int (because JSON turns ints into floats)
		if ParseUtils.dictionary_has_number(_base_data, PRESET_ID_KEY):
			_base_data[PRESET_ID_KEY] = (
					ParseUtils.dictionary_int(_base_data, PRESET_ID_KEY)
			)

## A list of all the diplomatic actions
## this country can perform with the other country.
var _base_action_ids: Array[int] = []

## The list of all available actions, including base actions and
## actions defined in the preset. This list is automatically updated.
var _available_actions: Array[DiplomacyAction] = []

var _turn_changed_signal: Signal


func _init(
		source_country_: Country,
		recipient_country_: Country,
		turn_changed_signal: Signal,
		base_data: Dictionary = {},
		base_action_ids: Array[int] = []
) -> void:
	source_country = source_country_
	recipient_country = recipient_country_
	_turn_changed_signal = turn_changed_signal
	_base_data = base_data
	_base_action_ids = base_action_ids


## The current preset associated with this relationship.
## A preset's data overrides this object's base data.
## There may be none, in which case this returns a new empty preset.
func preset() -> DiplomacyPreset:
	return diplomacy_presets.preset_from_id(_preset_id())


## If true, the country grants explicit permission to the recipient
## to move their armies into their provinces.
func grants_military_access() -> bool:
	return _get_data(
			GRANTS_MILITARY_ACCESS_KEY,
			GRANTS_MILITARY_ACCESS_DEFAULT
	)


## If true, the country will move its armies into the recipient's
## provinces without permission.
func is_trespassing() -> bool:
	return _get_data(
			IS_TRESPASSING_KEY,
			IS_TRESPASSING_DEFAULT
	)


## If true, the country will unconditionally engage in combat with
## any of the recipient's armies.
func is_fighting() -> bool:
	return _get_data(
			IS_FIGHTING_KEY,
			IS_FIGHTING_DEFAULT
	)


## Call this once after loading to initialize the list of available actions.
func initialize_actions(
		current_turn: int,
		actions_already_performed: Array[int] = []
) -> void:
	_update_available_actions(current_turn)
	for action in _available_actions:
		if action.id() in actions_already_performed:
			action._was_performed_this_turn = true


# TODO sort the actions in the right order (as defined in the game rules)
## Returns the actions that are currently available to this country.
## The list has no duplicates.
func available_actions() -> Array[DiplomacyAction]:
	return _available_actions.duplicate()


## If there is no available action with given id, returns an empty action.
func action_from_id(action_id: int) -> DiplomacyAction:
	for action in _available_actions:
		if action.id() == action_id:
			return action
	return DiplomacyAction.new(diplomacy_actions.empty(), _turn_changed_signal)


func action_is_available(action_id: int) -> bool:
	for action in _available_actions:
		if action.id() == action_id:
			return true
	return false


## Applies the outcome of a [DiplomacyAction] to this relationship.
func apply_action_data(data: Dictionary, current_turn: int) -> void:
	var preset_id_before: int = _preset_id()
	var grants_military_access_before: bool = grants_military_access()
	var is_trespassing_before: bool = is_trespassing()
	var is_fighting_before: bool = is_fighting()
	
	_base_data.merge(data, true)
	
	if _preset_id() != preset_id_before:
		preset_changed.emit(self)
	if grants_military_access() != grants_military_access_before:
		military_access_changed.emit(self)
	if is_trespassing() != is_trespassing_before:
		trespassing_changed.emit(self)
	if is_fighting() != is_fighting_before:
		fighting_changed.emit(self)
	
	_update_available_actions(current_turn)


## Needs the current turn for providing time stamps in new actions.
## Some actions may only be performed after some number of turns.
func _update_available_actions(current_turn: int) -> void:
	var new_available_actions: Array[DiplomacyAction] = []
	
	# It's important here that we iterate through
	# all of the preset's actions first, so they they have priority
	# over the base actions when checking for duplicates
	var action_id_list: Array[int] = []
	action_id_list.append_array(preset().actions)
	
	# ATTENTION TODO don't hard code these conditions...
	for base_action_id in _base_action_ids:
		match base_action_id:
			# Military access...
			5:
				if not grants_military_access():
					action_id_list.append(base_action_id)
			6:
				if grants_military_access():
					action_id_list.append(base_action_id)
			7:
				if (
						not recipient_country.relationships
						.with_country(source_country).grants_military_access()
				):
					action_id_list.append(base_action_id)
			# Trespassing...
			8:
				if not is_trespassing():
					action_id_list.append(base_action_id)
			9:
				if is_trespassing():
					action_id_list.append(base_action_id)
			10:
				if (
						recipient_country.relationships
						.with_country(source_country).is_trespassing()
				):
					action_id_list.append(base_action_id)
			# Fighting...
			11:
				if not is_fighting():
					action_id_list.append(base_action_id)
			12:
				if is_fighting():
					action_id_list.append(base_action_id)
			13:
				if (
						recipient_country.relationships
						.with_country(source_country).is_fighting()
				):
					action_id_list.append(base_action_id)
			_:
				action_id_list.append(base_action_id)
	
	var used_ids: Array[int] = []
	for action_id in action_id_list:
		# Avoid duplicates
		if action_id in used_ids:
			continue
		
		if action_is_available(action_id):
			new_available_actions.append(action_from_id(action_id))
		else:
			new_available_actions.append(DiplomacyAction.new(
					diplomacy_actions.action_from_id(action_id),
					_turn_changed_signal,
					current_turn
			))
		used_ids.append(action_id)
	
	var old_available_actions: Array[DiplomacyAction] = (
			_available_actions.duplicate()
	)
	_available_actions = new_available_actions
	
	if _available_actions_changed(old_available_actions, _available_actions):
		available_actions_changed.emit(self)


## Compares the two given lists and returns false if they both
## contain the same elements, in any order. Otherwise, returns true.
func _available_actions_changed(
		old_actions: Array[DiplomacyAction],
		new_actions: Array[DiplomacyAction]
) -> bool:
	if old_actions.size() != new_actions.size():
		return true
	
	for old_action in old_actions:
		if not new_actions.has(old_action):
			return true
	
	return false


## Returns the data associated with given key.
## Looks in the preset's data first, and if the preset doesn't have the key,
## then it looks in this object's base data.
## If it's not there either, returns the given default value.
## Always returns something of the same type as given default value.
func _get_data(key: String, default_value: Variant) -> Variant:
	return _get_data_recursive(
			key, default_value, [preset().settings, _base_data]
	)


## Looks for given key in each given dictionary, starting with the first one
## in the list. If the first dictionary doesn't have the key, then it looks
## for it in the second dictionary, and so on. If it can't find the key
## in any dictionary, then it will return the given default value.
## If a dictionary has the key but its value is not the correct type
## (it has to be the same type as given default value),
## ignores it and moves on to the next dictionary.
## Always returns something of the same type as given default value.
func _get_data_recursive(
		key: String,
		default_value: Variant,
		fallbacks: Array[Dictionary],
		fallback_index: int = 0,
) -> Variant:
	if fallback_index >= fallbacks.size():
		return default_value
	
	var dictionary: Dictionary = fallbacks[fallback_index]
	if not dictionary.has(key):
		return _get_data_recursive(
				key, default_value, fallbacks, fallback_index + 1
		)
	
	var value: Variant = dictionary[key]
	if typeof(value) != typeof(default_value):
		push_warning(
				"Diplomacy relationship data value is of wrong type. "
				+ "It's a " + type_string(typeof(value))
				+ ", but it should be a " + type_string(typeof(default_value))
				+ ". Ignoring."
		)
		return _get_data_recursive(
				key, default_value, fallbacks, fallback_index + 1
		)
	
	return value


func _preset_id() -> int:
	return _get_data_recursive(PRESET_ID_KEY, PRESET_ID_DEFAULT, [_base_data])


## Returns the base data, but if a value in the base data
## matches a given default value, it's not included in the output.
func _base_data_no_defaults(default_data: Dictionary) -> Dictionary:
	var output: Dictionary = {}
	for key: Variant in _base_data.keys():
		if not (
				default_data.has(key)
				and _base_data[key] == default_data[key]
		):
			output[key] = _base_data[key]
	return output
