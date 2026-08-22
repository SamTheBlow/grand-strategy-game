class_name InterfaceDiplomacy
extends AppEditorInterface
## Interface where the user can add/remove/edit diplomacy-related components.


func _ready() -> void:
	const COMPONENT_KEYS: Array[String] = [
		RelationshipPresetDefault.KEY,
		RelationshipPresetRandomization.KEY,
		DiplomacySettings.KEY,
		MilitaryAccessLossBehavior.KEY,
	]
	var components_section := %ComponentSection as ComponentSection
	components_section.setup(COMPONENT_KEYS, project, undo_redo)

	closed.connect(navigator.close_interface)
