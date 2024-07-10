class_name DiplomacyActionFromId
## Class responsible for retrieving a [DiplomacyAction] with given id.


func result(actions: Array[DiplomacyAction], id: int) -> DiplomacyAction:
	for action in actions:
		if action.id == id:
			return action
	push_error("Failed to find diplomacy action with id: " + str(id))
	return null
