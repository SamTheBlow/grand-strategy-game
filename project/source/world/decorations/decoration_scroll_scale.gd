class_name DecorationScrollScale
extends Node
## Scales currently dragged world decoration using the mouse wheel.

## What the scale is multiplied by when the wheel is scrolled.
const _SCALE_FACTOR: float = 1.1
const _INVERSE_SCALE_FACTOR: float = 1.0 / _SCALE_FACTOR

@export var _undo_redo: UndoRedoResource

## May be null.
var _selected_decoration: WorldDecoration = null:
	set = set_selected_decoration

var _is_being_dragged: bool = false:
	set = set_is_being_dragged


func _ready() -> void:
	set_process_input(_selected_decoration != null and _is_being_dragged)


func _input(event: InputEvent) -> void:
	var event_button := event as InputEventMouseButton
	if event_button == null or not event_button.pressed:
		return

	var factor: float = 1.0
	match event_button.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			factor = _INVERSE_SCALE_FACTOR
		MOUSE_BUTTON_WHEEL_DOWN:
			factor = _SCALE_FACTOR
		_:
			return

	_undo_redo.create_action("Scale world decoration", UndoRedo.MERGE_ENDS)
	_undo_redo.add_do_property(
			_selected_decoration, &"scale", _selected_decoration.scale * factor
	)
	_undo_redo.add_undo_property(
			_selected_decoration, &"scale", _selected_decoration.scale
	)
	_undo_redo.commit_action()

	get_viewport().set_input_as_handled()


## Deselects if input is empty or null.
func set_selected_decoration(value: WorldDecoration = null) -> void:
	_selected_decoration = value
	set_process_input(_selected_decoration != null and _is_being_dragged)


func set_is_being_dragged(value: bool) -> void:
	_is_being_dragged = value
	set_process_input(_selected_decoration != null and _is_being_dragged)
