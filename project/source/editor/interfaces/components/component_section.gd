class_name ComponentSection
extends VBoxContainer
## Displays given set of [GameComponent]s for the user to toggle and edit.

const _COMPONENT_EDITOR_SCENE: PackedScene = preload("uid://c1t8lbl0uvqnm")


func setup(
		keys: Array[String], project: GameProject, undo_redo: UndoRedoResource
) -> void:
	var container_node: Node = %Content
	for key: String in keys:
		var parse_result: GameComponent.ParseResult = (
				GameComponent.from_key(key)
		)
		if parse_result.error:
			continue

		var editor := _COMPONENT_EDITOR_SCENE.instantiate() as ComponentEditor
		editor.setup(parse_result.result_component, project, undo_redo)
		container_node.add_child(editor)
