class_name PositionEdit
extends Node2D
## Displays a 2D point that you can move around with your mouse.

signal position_changed(new_position: Vector2)
signal drag_finished(start_position: Vector2, end_position: Vector2)

enum PointShape {
	SQUARE,
	CIRCLE,
}

const _POINT_COLOR := Color(0.0, 0.5, 1.0, 0.7)
const _POINT_HOVERED_COLOR := Color.WHITE
const _POINT_RADIUS: float = 6.0
const _CURSOR_THRESHOLD: float = 6.0

var _text: String = ""
var _point_shape: PointShape
var _is_hovered: bool = false
var _is_dragging: bool = false
var _start_position := Vector2.ZERO


func _init(text: String = "", point_shape := PointShape.CIRCLE) -> void:
	_text = text
	_point_shape = point_shape


func _draw() -> void:
	const POINT_OUTLINE_THICKNESS: float = 1.0
	const POINT_OUTLINE_RADIUS: float = (
		_POINT_RADIUS + POINT_OUTLINE_THICKNESS * 0.5
	)

	match _point_shape:
		PointShape.SQUARE:
			# Outline
			draw_rect(
					Rect2(
							-POINT_OUTLINE_RADIUS,
							-POINT_OUTLINE_RADIUS,
							2.0 * POINT_OUTLINE_RADIUS,
							2.0 * POINT_OUTLINE_RADIUS
					),
					Color.BLACK,
					false,
					POINT_OUTLINE_THICKNESS
			)
			# The actual square
			draw_rect(
					Rect2(
							-_POINT_RADIUS,
							-_POINT_RADIUS,
							2.0 * _POINT_RADIUS,
							2.0 * _POINT_RADIUS
					),
					_POINT_HOVERED_COLOR if _is_hovered else _POINT_COLOR
			)
		PointShape.CIRCLE:
			# Outline
			draw_circle(
					Vector2.ZERO,
					POINT_OUTLINE_RADIUS,
					Color.BLACK,
					false,
					POINT_OUTLINE_THICKNESS
			)
			# The actual circle
			draw_circle(
					Vector2.ZERO,
					_POINT_RADIUS,
					_POINT_HOVERED_COLOR if _is_hovered else _POINT_COLOR
			)
		_:
			pass

	if _is_hovered:
		# Outline
		const TEXT_OUTLINE_THICKNESS: int = 12
		draw_string_outline(
				ThemeDB.get_default_theme().default_font,
				Vector2(-5000.0, -16.0),
				_text,
				HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER,
				10000.0,
				16,
				TEXT_OUTLINE_THICKNESS,
				Color.BLACK
		)
		# The actual text
		draw_string(
				ThemeDB.get_default_theme().default_font,
				Vector2(-5000.0, -16.0),
				_text,
				HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER,
				10000.0,
				16,
				Color.WHITE
		)


func _unhandled_input(event: InputEvent) -> void:
	if _handle_left_click(event) or _handle_mouse_motion(event):
		get_viewport().set_input_as_handled()


func _handle_left_click(event: InputEvent) -> bool:
	if event is not InputEventMouseButton:
		return false
	var event_mouse_button := event as InputEventMouseButton

	if event_mouse_button.button_index != MOUSE_BUTTON_LEFT:
		return false

	if event_mouse_button.is_pressed() and _is_hovered:
		_is_dragging = true
		_start_position = position
		return true

	if event_mouse_button.is_released() and _is_dragging:
		_is_dragging = false
		drag_finished.emit(_start_position, position)
		return true

	return false


func _handle_mouse_motion(event: InputEvent) -> bool:
	if event is not InputEventMouseMotion:
		return false

	var global_mouse_position: Vector2 = get_global_mouse_position()

	if _is_dragging:
		position = global_mouse_position
		position_changed.emit(position)
		queue_redraw()
		return true

	var previous_is_hovered: bool = _is_hovered
	_is_hovered = (
			(global_mouse_position - position).length() < _CURSOR_THRESHOLD
	)
	if previous_is_hovered != _is_hovered:
		queue_redraw()

	return false
