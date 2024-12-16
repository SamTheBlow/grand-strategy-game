class_name Editor
extends Node
## The game editor where users make their own games.

signal exited()

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
	if _current_project.name == "":
		return "(Unnamed project) - "
	return _current_project.name + " - "


## Called when the user clicks on one of the options in the menu bar.
func _on_menu_id_pressed(id: int) -> void:
	match id:
		0:
			# "Quit"
			exited.emit()
		_:
			push_error("Unrecognized menu id.")
