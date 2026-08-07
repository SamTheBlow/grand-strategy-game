class_name ProjectOpener
extends Node
## Creates a popup for loading an existing [GameProject].
## Emits a signal to indicate a project was opened.

signal project_opened(project: GameProject)

const _GAME_POPUP_SCENE: PackedScene = preload("uid://by865efl4iwy")
const _PROJECT_LOAD_POPUP_SCENE: PackedScene = preload("uid://df5yjnsebj5np")

@onready var _popup_container := %PopupContainer as Control


func open_new_project() -> void:
	project_opened.emit(GameProject.new())


## Opens the popup that lets the user load a project.
func open_existing_project() -> void:
	var popup := _GAME_POPUP_SCENE.instantiate() as GamePopup
	var project_load_popup := (
			_PROJECT_LOAD_POPUP_SCENE.instantiate() as ProjectLoadPopup
	)
	project_load_popup.project_loaded.connect(project_opened.emit)
	popup.contents_node = project_load_popup
	_popup_container.add_child(popup)
