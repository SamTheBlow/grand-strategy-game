class_name DiplomacyRelationship
## Represents how one country behaves in relation with given country.
##
## Note: when saving/loading the data with something that doesn't
## differentiate floats and ints (e.g. JSON), this class will not
## be responsible for converting floats to ints or vice versa.


const GRANTS_MILITARY_ACCESS_KEY: String = "grants_military_access"
const GRANTS_MILITARY_ACCESS_DEFAULT: bool = false

const IS_TRESPASSING_KEY: String = "is_trespassing"
const IS_TRESPASSING_DEFAULT: bool = true

const IS_FIGHTING_KEY: String = "is_fighting"
const IS_FIGHTING_DEFAULT: bool = true

var recipient_country: Country

## The preset's data overrides this object's base data.
## If you don't want to use presets, you can leave this as is:
## an empty preset has no effect by default.
var preset := DiplomacyPreset.new()

## Information about the relationship.
## It's possible to add/change/remove data using diplomatic actions.
var _base_data: Dictionary = {}

## A list of all the diplomatic actions
## this country can perform with the other country.
var _base_actions: Array[DiplomacyAction] = []


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
## Returns a list of all the diplomatic actions this country can perform,
## including the preset's actions. There will be no duplicates.
func actions() -> Array[DiplomacyAction]:
	var output: Array[DiplomacyAction] = []
	output.append_array(_base_actions)
	
	for preset_action in preset.actions:
		var is_new_action: bool = true
		for action in output:
			if action.id == preset_action.id:
				is_new_action = false
				break
		if is_new_action:
			output.append(preset_action)
	
	return output


## Returns the data associated with given key.
## Looks in the preset's data first, and if the preset doesn't have the key,
## then it looks in this object's base data.
## If it's not there either, returns the given default value.
## Always returns something of the same type as given default value.
func _get_data(key: String, default_value: Variant) -> Variant:
	# Prevent crash
	if preset == null:
		push_error("Diplomacy preset is null. Setting new empty preset.")
		preset = DiplomacyPreset.new()
	
	return _get_data_recursive(
			key, default_value, [preset.settings, _base_data]
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
