class_name DiplomacyPresets


# TODO populate this the right way
var _presets: Array[DiplomacyPreset] = [
	load("res://resources/diplomacy/presets/allied.tres"),
	load("res://resources/diplomacy/presets/neutral.tres"),
	load("res://resources/diplomacy/presets/at_war.tres"),
]


## Returns a new empty preset if there is no preset with given id.
## Inputting a negative number automatically returns
## a new empty preset, without pushing any error.
func preset_from_id(id: int) -> DiplomacyPreset:
	if id < 0:
		return DiplomacyPreset.new()
	
	for preset in _presets:
		if preset.id == id:
			return preset
	
	push_error("Failed to find diplomacy preset with id: " + str(id))
	return DiplomacyPreset.new()
