class_name ProjectNode
extends Node
## Holds a [GameProject]. Provides useful functions and signals.

signal has_valid_file_path_changed(has_valid_file_path: bool)
signal project_name_changed(name: String)

var _project: GameProject:
	set(value):
		if _project == value:
			return

		if _project != null:
			_project.file_path_changed.disconnect(_emit_file_path_change)
			_project.metadata.name_changed.disconnect(_emit_name_change)

		_project = value

		_emit_file_path_change()
		_project.file_path_changed.connect(_emit_file_path_change)

		_emit_name_change()
		_project.metadata.name_changed.connect(_emit_name_change)


func set_project(project: GameProject) -> void:
	_project = project


## No effect if current project doesn't have a valid file path.
func show_in_file_manager() -> void:
	if _project.has_valid_file_path():
		OS.shell_show_in_file_manager(_project.file_path())


func _emit_file_path_change() -> void:
	has_valid_file_path_changed.emit(_project.has_valid_file_path())


func _emit_name_change() -> void:
	project_name_changed.emit(_project.metadata.project_name_or_default())
