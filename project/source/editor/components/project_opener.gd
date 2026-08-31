extends Node
## Creates a [ProjectLoadPopup] when the user wants to load a project.
## Emits a signal when a project is opened.

signal popup_created(contents: Node)
signal project_opened(project: GameProject)

const _POPUP_CONTENTS_SCENE: PackedScene = preload("uid://df5yjnsebj5np")


func open_new_project() -> void:
	project_opened.emit(GameProject.new())


func open_existing_project() -> void:
	var popup := _POPUP_CONTENTS_SCENE.instantiate() as ProjectLoadPopup
	popup.project_loaded.connect(project_opened.emit)
	popup_created.emit(popup)
