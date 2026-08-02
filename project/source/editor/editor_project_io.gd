class_name EditorProjectIO
extends Node
## Handles creating, opening, and saving [GameProject]s.

signal project_loaded(project: GameProject)
signal project_saved()

const _GAME_POPUP_SCENE: PackedScene = preload("uid://by865efl4iwy")
const _PROJECT_LOAD_POPUP_SCENE: PackedScene = preload("uid://df5yjnsebj5np")

var current_project: GameProject

@onready var _popup_container := %PopupContainer as Control
@onready var _save_dialog := %SaveDialog as FileDialog


func _open_new_project() -> void:
	project_loaded.emit(GameProject.new())


## Opens the popup that lets the user load a project.
func _open_project() -> void:
	var popup := _GAME_POPUP_SCENE.instantiate() as GamePopup
	var project_load_popup := (
			_PROJECT_LOAD_POPUP_SCENE.instantiate() as ProjectLoadPopup
	)
	project_load_popup.project_loaded.connect(project_loaded.emit)
	popup.contents_node = project_load_popup
	_popup_container.add_child(popup)


## If the project doesn't have a file path assigned, opens the file dialog.
func _save_project() -> void:
	if current_project.has_valid_file_path():
		current_project.save()
		project_saved.emit()
	else:
		_save_dialog.show()


func _on_save_dialog_file_selected(file_path: String) -> void:
	# Add the file extension if the user didn't type it in
	if not file_path.to_lower().ends_with(".json"):
		file_path = file_path + ".json"

	current_project.save_as(file_path)
	project_saved.emit()
