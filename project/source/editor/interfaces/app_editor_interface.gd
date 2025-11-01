class_name AppEditorInterface
extends Control
## Base class for the editing interface in the [Editor].

var editor_settings := AppEditorSettings.new():
	set(value):
		editor_settings = value
		_update_editor_settings()

var undo_redo := UndoRedo.new()


func _ready() -> void:
	_update_editor_settings()


func _update_editor_settings() -> void:
	pass
