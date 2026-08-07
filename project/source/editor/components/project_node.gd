class_name ProjectNode
extends Node
## Holds a [GameProject]. Provides useful functions and signals.

## Emits when the current project is about to change.
## Use this signal to clear existing data.
signal project_changing()
## Emits when the current project has changed.
signal project_changed(project: GameProject)

signal save_dialog_requested()
signal saved()

signal has_valid_file_path_changed(has_valid_file_path: bool)
signal project_name_changed(name: String)

var _project: GameProject:
	set(value):
		if _project == value:
			return

		if _project != null:
			_project.file_path_changed.disconnect(_emit_file_path_change)
			_project.metadata.name_changed.disconnect(_emit_name_change)
			project_changing.emit()

		_project = value

		_emit_file_path_change()
		_project.file_path_changed.connect(_emit_file_path_change)

		_emit_name_change()
		_project.metadata.name_changed.connect(_emit_name_change)

		project_changed.emit(_project)


func _ready() -> void:
	_project = GameProject.new()


func set_project(project: GameProject) -> void:
	_project = project


## No effect if current project doesn't have a valid file path.
func show_in_file_manager() -> void:
	if _project.has_valid_file_path():
		OS.shell_show_in_file_manager(_project.file_path())


## Saves the project to its assigned file path.
## If project doesn't have a file path assigned, opens the file dialog instead.
func save() -> void:
	if not _project.has_valid_file_path():
		save_dialog_requested.emit()
		return

	var project_save := ProjectSave.new()
	project_save.save_project(_project)

	if project_save.error:
		push_warning(project_save.error_message)
	else:
		saved.emit()


func save_as(file_path: String) -> void:
	# Add the file extension if the user didn't type it in
	if not file_path.to_lower().ends_with(".json"):
		file_path = file_path + ".json"

	_project.set_file_path(file_path)
	save()


func _emit_file_path_change() -> void:
	has_valid_file_path_changed.emit(_project.has_valid_file_path())


func _emit_name_change() -> void:
	project_name_changed.emit(_project.metadata.project_name_or_default())
