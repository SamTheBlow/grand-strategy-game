class_name ProjectLoadPopup
extends Container
## The popup that appears when the user wishes to load an [EditorProject].
## See also: [GamePopup]

signal project_loaded(project: EditorProject)


func buttons() -> Array[String]:
	return ["Load", "Cancel"]


func _on_button_pressed(button_id: int) -> void:
	if button_id == 0:
		var test := EditorProject.new()
		test.name = "Amogus"
		project_loaded.emit(test)
