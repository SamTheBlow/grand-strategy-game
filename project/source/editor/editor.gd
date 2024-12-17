class_name Editor
extends Node
## The game editor where users make their own games.

signal exited()

## The scene's root node must be a [GamePopup].
@export var _popup_scene: PackedScene
## The scene's root node must be a [ProjectLoadPopup].
@export var _project_load_popup_scene: PackedScene

var _current_project: EditorProject:
	set(value):
		_current_project = value
		_update_window_title()


func _ready() -> void:
	_current_project = EditorProject.new()


func _exit_tree() -> void:
	# Reset the window title
	_current_project = null


func _update_window_title() -> void:
	get_window().title = (
			_window_title_prefix()
			+ ProjectSettings.get_setting("application/config/name", "")
	)


## If there is no current project, returns an empty string.
func _window_title_prefix() -> String:
	if _current_project == null:
		return ""
	return _current_project.name + " - "


## Called when the user clicks on one of the options in the menu bar.
func _on_menu_id_pressed(id: int) -> void:
	match id:
		0:
			# "Open..."
			var popup := _popup_scene.instantiate() as GamePopup
			var project_load_popup := (
					_project_load_popup_scene.instantiate() as ProjectLoadPopup
			)
			project_load_popup.project_loaded.connect(_on_project_loaded)
			popup.contents_node = project_load_popup
			add_child(popup)
		1:
			# "Quit"
			exited.emit()
		_:
			push_error("Unrecognized menu id.")


func _on_project_loaded(project: EditorProject) -> void:
	_current_project = project
