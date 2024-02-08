class_name Player


var id: int

var playing_country: Country

var actions: Array[Action] = []


func add_action(action: Action) -> void:
	actions.append(action)


func clear_actions() -> void:
	actions.clear()
