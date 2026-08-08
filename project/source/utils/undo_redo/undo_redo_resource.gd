class_name UndoRedoResource
extends Resource
## Encapsulates an [UndoRedo] system so it can be shared between nodes.

signal version_changed()

var _undo_redo := UndoRedo.new()


func _init() -> void:
	_undo_redo = UndoRedo.new()
	_undo_redo.version_changed.connect(version_changed.emit)


func reset() -> void:
	# Create a new instance so that the version number is also reset
	_undo_redo.version_changed.disconnect(version_changed.emit)
	_undo_redo = UndoRedo.new()
	_undo_redo.version_changed.connect(version_changed.emit)


func create_action(
		name: String, merge_mode: int = 0, backward_undo_ops: bool = true
) -> void:
	_undo_redo.create_action(name, merge_mode, backward_undo_ops)


func add_do_method(callable: Callable) -> void:
	_undo_redo.add_do_method(callable)


func add_undo_method(callable: Callable) -> void:
	_undo_redo.add_undo_method(callable)


func add_do_property(
		object: Object, property: StringName, value: Variant
) -> void:
	_undo_redo.add_do_property(object, property, value)


func add_undo_property(
		object: Object, property: StringName, value: Variant
) -> void:
	_undo_redo.add_undo_property(object, property, value)


func add_do_reference(object: Object) -> void:
	_undo_redo.add_do_reference(object)


func add_undo_reference(object: Object) -> void:
	_undo_redo.add_undo_reference(object)


func commit_action(execute: bool = true) -> void:
	_undo_redo.commit_action(execute)


func undo() -> void:
	_undo_redo.undo()


func redo() -> void:
	_undo_redo.redo()


func get_version() -> int:
	return _undo_redo.get_version()


func get_history_count() -> int:
	return _undo_redo.get_history_count()


func get_action_name(index: int) -> String:
	return _undo_redo.get_action_name(index)
