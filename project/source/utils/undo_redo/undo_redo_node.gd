class_name UndoRedoNode
extends Node
## Applies undo/redo according to user input.
## Keeps track of dirty state.

signal is_dirty_changed(is_dirty: bool)

@export var _undo_redo: UndoRedoResource

var _is_dirty: bool = false:
	set(value):
		if _is_dirty == value:
			return
		_is_dirty = value
		is_dirty_changed.emit(_is_dirty)

## The undo version at which the project was last saved.
## Used to determine whether the project has unsaved changes.
var _saved_version: int = 1


func _ready() -> void:
	_update_is_dirty()
	_undo_redo.version_changed.connect(_update_is_dirty)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_undo"):
		_undo_redo.undo()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_redo"):
		_undo_redo.redo()
		get_viewport().set_input_as_handled()


func reset() -> void:
	_undo_redo.reset()
	_saved_version = 1
	_is_dirty = false


## Marks the current history state as saved.
func mark_saved() -> void:
	_saved_version = _undo_redo.get_version()
	_is_dirty = false


func _update_is_dirty() -> void:
	_is_dirty = _undo_redo.get_version() != _saved_version
