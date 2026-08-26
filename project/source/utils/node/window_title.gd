class_name WindowTitle
extends Node
## Handles the window's title in some editor.
## Shows the name of current project and whether it has unsaved changes.

var _project_name: String = ""
var _is_dirty: bool = false

var _base_title: String = (
		ProjectSettings.get_setting("application/config/name", "")
)


func _enter_tree() -> void:
	# Restore the window title when this node is re-added.
	_refresh()


func _exit_tree() -> void:
	# Reset the window title when this node is removed.
	get_window().title = _base_title


func set_project_name(new_name: String) -> void:
	_project_name = new_name
	_refresh()


func set_is_dirty(is_dirty: bool) -> void:
	_is_dirty = is_dirty
	_refresh()


func _refresh() -> void:
	var dirty_indicator: String = "*" if _is_dirty else ""
	get_window().title = dirty_indicator + _project_name + " - " + _base_title
