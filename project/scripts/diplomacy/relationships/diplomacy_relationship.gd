class_name DiplomacyRelationship
## Represents how one country behaves in relation with given country.
##
## Note: when saving/loading the data with something that doesn't
## differentiate floats and ints (e.g. JSON), this class will not
## be responsible for converting floats to ints or vice versa.


const PRESET_ID_KEY: String = "preset_id"
const PRESET_ID_DEFAULT: int = -1

const GRANTS_MILITARY_ACCESS_KEY: String = "grants_military_access"
const GRANTS_MILITARY_ACCESS_DEFAULT: bool = false

const IS_TRESPASSING_KEY: String = "is_trespassing"
const IS_TRESPASSING_DEFAULT: bool = true

const IS_FIGHTING_KEY: String = "is_fighting"
const IS_FIGHTING_DEFAULT: bool = true

var recipient_country: Country

## The game's registered diplomacy presets.
## Only these presets may be used in this relationship.
var diplomacy_presets: DiplomacyPresets = DiplomacyPresets.new()

## Information about the relationship.
## It's possible to add/change/remove data using diplomatic actions.
var _base_data: Dictionary = {}

## A list of all the diplomatic actions
## this country can perform with the other country.
var _base_action_ids: Array[int] = []


## The current preset associated with this relationship.
## A preset's data overrides this object's base data.
## There may be none, in which case this returns a new empty preset.
func preset() -> DiplomacyPreset:
	var preset_id: int = _get_data_recursive(
			PRESET_ID_KEY, PRESET_ID_DEFAULT, [_base_data]
	)
	return diplomacy_presets.preset_from_id(preset_id)


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


# TODO sort the actions in the right order (as defined in the game rules)
## Filters the given list of diplomatic actions to only return
## the actions that are currently available to this country.
func available_actions(
		action_list: Array[DiplomacyAction]
) -> Array[DiplomacyAction]:
	var output: Array[DiplomacyAction] = []
	var available_action_ids_: Array[int] = available_action_ids()
	
	for action in action_list:
		if action.id in available_action_ids_:
			output.append(action)
	
	return output


## Returns a list of all the available actions, as a list of action ids.
## The list has no duplicates.
func available_action_ids() -> Array[int]:
	var output: Array[int] = []
	output.append_array(_base_action_ids)
	
	for preset_action_id in preset().actions:
		var is_new_action: bool = true
		for action_id in output:
			if action_id == preset_action_id:
				is_new_action = false
				break
		if is_new_action:
			output.append(preset_action_id)
	
	return output


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
				"Diplomacy relationship data value is of wrong type. Ignoring."
		)
		return _get_data_recursive(
				key, default_value, fallbacks, fallback_index + 1
		)
	
	return value
