class_name EditorHistory
extends Node
## Handles the editor's undo/redo system.

signal initialized(undo_redo: UndoRedo)
signal version_changed()

var _undo_redo: UndoRedo

## The undo version at which the project was last saved.
## Used to determine whether the project has unsaved changes.
var _saved_version: int = 1


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_undo"):
		_undo_redo.undo()
	elif Input.is_action_just_pressed(&"ui_redo"):
		_undo_redo.redo()


## Discards the current history and starts a new one.
func reset() -> void:
	if _undo_redo != null:
		_undo_redo.version_changed.disconnect(version_changed.emit)
	_undo_redo = UndoRedo.new()
	_undo_redo.version_changed.connect(version_changed.emit)
	initialized.emit(_undo_redo)


## Returns true if the project has unsaved changes.
func is_dirty() -> bool:
	return _undo_redo.get_version() != _saved_version


## Marks the current history state as saved.
func _mark_saved() -> void:
	_saved_version = _undo_redo.get_version()
