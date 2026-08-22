class_name InterfaceWinConditions
extends AppEditorInterface
## Interface where the user can add/remove/edit a game's win conditions.


func _ready() -> void:
	const COMPONENT_KEYS: Array[String] = [
		TurnLimit.KEY,
		ProvinceControlGoal.KEY
	]
	var components_section := %ComponentSection as ComponentSection
	components_section.setup(COMPONENT_KEYS, project, undo_redo)

	closed.connect(navigator.close_interface)
