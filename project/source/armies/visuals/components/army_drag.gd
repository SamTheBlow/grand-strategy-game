class_name ArmyDrag
extends Node
## Implements dragging an army with the mouse.

## Used to get currently selected/hovered army.
@export var _army_selection: ArmySelection
## Used to get visuals of currently selected army.
@export var _army_visuals_list: ArmyVisualsSetup
## Used to get currently hovered province.
@export var _province_visuals_input: ProvinceVisualsInput
## Used to implement undo/redo for the army's movement.
@export var _undo_redo: UndoRedoResource

## Used to move the army.
var _project: GameProject

## Keeps track of the visuals being dragged. May be null.
var _dragged_visuals: ArmyVisuals2D = null:
	set(value):
		if _dragged_visuals != null:
			_dragged_visuals.tree_exited.disconnect(_cancel_drag)
		_dragged_visuals = value
		if _dragged_visuals != null:
			_dragged_visuals.tree_exited.connect(_cancel_drag)

## Keeps track of where the visuals were so we can move them back there later.
var _drag_start_position := Vector2.ZERO


func set_project(value: GameProject) -> void:
	_project = value


func _cancel_drag() -> void:
	if _dragged_visuals != null:
		_dragged_visuals.position = _drag_start_position
		_dragged_visuals = null


func _on_drag_started() -> void:
	var selected_army: Army = _army_selection.selected_army()
	if selected_army == null:
		return

	var hovered_army: Army = _army_selection.hovered_army()
	if hovered_army == null or hovered_army != selected_army:
		return

	_dragged_visuals = _army_visuals_list.visuals_of(selected_army)
	if _dragged_visuals == null:
		return

	# You are now dragging an army
	_drag_start_position = _dragged_visuals.position
	get_viewport().set_input_as_handled()


func _on_drag_moved(delta: Vector2) -> void:
	if _dragged_visuals == null:
		return

	_dragged_visuals.position += delta


func _on_drag_ended() -> void:
	if _dragged_visuals == null:
		return

	var hovered_province: Province = _province_visuals_input.hovered_province()

	# Move army to hovered province
	if (
			hovered_province != null
			and hovered_province.id != _dragged_visuals.army.province_id()
	):
		_project.game.world.armies.undo_redo_move(
				_dragged_visuals.army,
				hovered_province.id,
				_undo_redo,
				_project.game.world.armies_in_each_province
		)

	_cancel_drag()
	get_viewport().set_input_as_handled()
