class_name DecorationVisualsInput
extends Node
## - Enables input on all decoration visuals.
## - Keeps track of which decoration is currently selected
##   and which decoration is currently hovered.
## - Adds or removes highlight on decoration visuals accordingly.
## - Emits a signal when a decoration is selected or deselected.
## - Handles dragging the selected decoration with the mouse.

signal selected(decoration: WorldDecoration)
signal deselected()
signal draggability_changed(is_enabled: bool)

@export var _undo_redo: UndoRedoResource

## This is used to apply highlights
@export var _decoration_container: DecorationVisualsContainer2D

## May be null.
var _selected_decoration: WorldDecoration = null
## May be null.
var _hovered_decoration: WorldDecoration = null

var _drag_position := Vector2.ZERO


## Deselects the decoration if input is empty or null.
## No effect if the decoration is already selected.
func set_selected_decoration(decoration: WorldDecoration = null) -> void:
	if decoration == _selected_decoration:
		return

	if _selected_decoration != null:
		var visuals: DecorationVisuals2D = (
				_decoration_container.visuals_of(_selected_decoration)
		)
		if visuals != null:
			if _selected_decoration == _hovered_decoration:
				visuals.highlight()
			else:
				visuals.remove_highlight()
		_selected_decoration = null
		deselected.emit()
		draggability_changed.emit(false)

	if decoration == null:
		return

	_selected_decoration = decoration
	_decoration_container.visuals_of(decoration).highlight_selected()
	selected.emit(decoration)
	draggability_changed.emit(_selected_decoration == _hovered_decoration)


## Sets it to none if input is empty or null.
## No effect if the decoration is already the hovered one.
func set_hovered_decoration(decoration: WorldDecoration = null) -> void:
	if decoration == _hovered_decoration:
		return

	if _hovered_decoration != null:
		if _hovered_decoration != _selected_decoration:
			var visuals: DecorationVisuals2D = (
					_decoration_container.visuals_of(_hovered_decoration)
			)
			if visuals != null:
				visuals.remove_highlight()
		_hovered_decoration = null
		draggability_changed.emit(false)

	if decoration == null:
		return

	_hovered_decoration = decoration
	if decoration != _selected_decoration:
		_decoration_container.visuals_of(decoration).highlight()
	draggability_changed.emit(_selected_decoration == _hovered_decoration)


func _setup_visuals(decoration_visuals: DecorationVisuals2D) -> void:
	decoration_visuals.is_input_enabled = true
	decoration_visuals.clicked.connect(
			_on_decoration_clicked.bind(decoration_visuals.world_decoration)
	)
	decoration_visuals.mouse_entered.connect(
			set_hovered_decoration.bind(decoration_visuals.world_decoration)
	)
	decoration_visuals.mouse_exited.connect(
			_unset_hovered_decoration,
			ConnectFlags.CONNECT_APPEND_SOURCE_OBJECT
	)
	decoration_visuals.tree_exited.connect(
			_unset_hovered_decoration,
			ConnectFlags.CONNECT_APPEND_SOURCE_OBJECT
	)


## We use this and not set_hovered_decoration(null),
## because if a different decoration got hovered and got their
## mouse_entered signal to trigger first, then they'd set the
## hovered decoration to the new decoration, and then the previous
## decoration visuals would trigger mouse_exited and set it back to null.
func _unset_hovered_decoration(decoration_visuals: DecorationVisuals2D) -> void:
	if _hovered_decoration == decoration_visuals.world_decoration:
		_hovered_decoration = null
		draggability_changed.emit(false)

	if decoration_visuals.world_decoration != _selected_decoration:
		decoration_visuals.remove_highlight()


func _on_decoration_clicked(decoration: WorldDecoration) -> void:
	if _selected_decoration == decoration:
		set_selected_decoration(null)
	else:
		set_selected_decoration(decoration)


func _on_drag_started() -> void:
	if _selected_decoration == null:
		return

	_drag_position = _selected_decoration.position


func _on_drag_moved(delta: Vector2) -> void:
	if _selected_decoration == null:
		return

	_selected_decoration.position += delta


func _on_drag_ended() -> void:
	if _selected_decoration == null:
		return

	var start_position: Vector2 = _drag_position
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
