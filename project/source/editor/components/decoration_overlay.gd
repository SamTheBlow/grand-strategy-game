class_name DecorationOverlay
extends Node2D
## Allows dragging the currently selected world decoration with the mouse.

var _undo_redo: UndoRedo
var _decoration_container: DecorationVisualsContainer2D

## May be null.
var _selected_decoration: WorldDecoration = null
var _is_dragging: bool = false
var _drag_start_position := Vector2.ZERO
var _cursor_position := Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if _selected_decoration == null:
		return

	var event_mouse_button := event as InputEventMouseButton
	if event_mouse_button != null:
		if event_mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return

		# Press to start drag
		if event_mouse_button.is_pressed():
			var visuals: DecorationVisuals2D = (
					_decoration_container.visuals_of(_selected_decoration)
			)
			if visuals != null and visuals.is_mouse_over():
				_is_dragging = true
				_drag_start_position = _selected_decoration.position
				_cursor_position = get_global_mouse_position()
				get_viewport().set_input_as_handled()
		# Release to end drag
		elif _is_dragging:
			_is_dragging = false
			_create_undo_redo()
			get_viewport().set_input_as_handled()

		return

	var event_mouse_motion := event as InputEventMouseMotion
	if event_mouse_motion != null and _is_dragging:
		var previous_cursor_position: Vector2 = _cursor_position
		_cursor_position = get_global_mouse_position()

		_selected_decoration.position += (
				_cursor_position - previous_cursor_position
		)
		get_viewport().set_input_as_handled()


func set_undo_redo(undo_redo: UndoRedo) -> void:
	_undo_redo = undo_redo


## Deselects if input is empty or null.
func set_selected_decoration(decoration: WorldDecoration = null) -> void:
	# Cancel drag
	if _is_dragging:
		_selected_decoration.position = _drag_start_position
		_is_dragging = false

	_selected_decoration = decoration


func _create_undo_redo() -> void:
	var start_position: Vector2 = _drag_start_position
	var end_position: Vector2 = _selected_decoration.position

	if start_position == end_position:
		return

	# Don't execute, it already moved
	_undo_redo.create_action("Move world decoration")
	_undo_redo.add_do_property(_selected_decoration, &"position", end_position)
	_undo_redo.add_undo_property(
			_selected_decoration, &"position", start_position
	)
	_undo_redo.commit_action(false)


func _on_world_loaded(world_visuals: WorldVisuals2D) -> void:
	# TODO ewww
	_decoration_container = (
			world_visuals.get_node("%Decorations")
			as DecorationVisualsContainer2D
	)
	set_selected_decoration(null)
