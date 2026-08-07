class_name UndoRedoNode
extends Node
## Encapsulates an [UndoRedo] system.
## Applies undo/redo according to user input. Provides useful signals.

signal initialized(undo_redo: UndoRedo)
signal is_dirty_changed(is_dirty: bool)

var _undo_redo: UndoRedo:
	set(value):
		if _undo_redo != null:
			_undo_redo.version_changed.disconnect(_update_is_dirty)

		_undo_redo = value

		_undo_redo.version_changed.connect(_update_is_dirty)
		initialized.emit(_undo_redo)

var _is_dirty: bool = false:
	set(value):
		if _is_dirty == value:
			return
		_is_dirty = value
		is_dirty_changed.emit(_is_dirty)

## The undo version at which the project was last saved.
## Used to determine whether the project has unsaved changes.
var _saved_version: int = 1


func _init() -> void:
	# Call the setter
	_undo_redo = UndoRedo.new()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_undo"):
		_undo_redo.undo()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_redo"):
		_undo_redo.redo()
		get_viewport().set_input_as_handled()


## Resets all internal data.
func reset() -> void:
	_undo_redo = UndoRedo.new()
	_saved_version = 1
	_is_dirty = false


## Marks the current history state as saved.
func mark_saved() -> void:
	_saved_version = _undo_redo.get_version()
	_is_dirty = false


func _update_is_dirty() -> void:
	_is_dirty = _undo_redo.get_version() != _saved_version
