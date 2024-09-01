class_name DiplomacyActionDefinitions
## A list of [DiplomacyActionDefinition]s.


var _empty := DiplomacyActionDefinition.new()
var _list: Array[DiplomacyActionDefinition] = []


func _init(list: Array[DiplomacyActionDefinition] = []) -> void:
	_list = list


## Returns null if there is no action with given id.
func action_from_id(id: int) -> DiplomacyActionDefinition:
	for action in _list:
		if action.id == id:
			return action
	push_error("Failed to find diplomacy action with id: " + str(id))
	return null


## Returns a reference to THE definition of the empty action.
func empty() -> DiplomacyActionDefinition:
	return _empty
