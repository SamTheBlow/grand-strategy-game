class_name DiplomacyPresets
## A list of [DiplomacyPreset]s.


var _list: Array[DiplomacyPreset] = []


func _init(list: Array[DiplomacyPreset] = []) -> void:
	_list = list


func is_id_valid(id: int) -> bool:
	for preset in _list:
		if preset.id == id:
			return true
	return false


## Returns a new empty preset if there is no preset with given id.
## Inputting a negative number automatically returns
## a new empty preset, without pushing any error.
func preset_from_id(id: int) -> DiplomacyPreset:
	if id < 0:
		return DiplomacyPreset.new()
	
	for preset in _list:
		if preset.id == id:
			return preset
	
	push_error("Failed to find diplomacy preset with id: " + str(id))
	return DiplomacyPreset.new()
