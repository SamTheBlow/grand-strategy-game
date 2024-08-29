class_name ProvinceShapePolygon2D
extends Polygon2D
## The visuals for a [Province]'s shape.
## Draws an outline around its polygon, when applicable, with given properties.


## Emitted when a mouse event occurs and the mouse cursor is on this shape.
## This one is only emitted when the event is unhandled.
signal unhandled_mouse_event_occured(event: InputEventMouse)
## Emitted when a mouse event occurs and the mouse cursor is on this shape.
signal mouse_event_occured(event: InputEventMouse)

enum OutlineType {
	NONE = 0,
	SELECTED = 1,
	HIGHLIGHT_TARGET = 2,
	HIGHLIGHT = 3,
}

@export var outline_color := Color.WEB_GRAY:
	set(value):
		outline_color = value
		queue_redraw()

@export var outline_width: float = 10.0:
	set(value):
		outline_width = value
		queue_redraw()

var _outline_type: OutlineType = OutlineType.NONE:
	set(value):
		_outline_type = value
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouse):
		return
	if not mouse_is_inside_shape():
		return
	unhandled_mouse_event_occured.emit(event as InputEventMouse)


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouse):
		return
	if not mouse_is_inside_shape():
		return
	mouse_event_occured.emit(event as InputEventMouse)


func _draw() -> void:
	match _outline_type:
		OutlineType.NONE:
			pass
		OutlineType.SELECTED:
			_draw_outline(get_polygon(), outline_color, outline_width)
		OutlineType.HIGHLIGHT_TARGET:
			_draw_outline(get_polygon(), outline_color, outline_width * 0.8)
		OutlineType.HIGHLIGHT:
			_draw_outline(get_polygon(), outline_color, outline_width * 0.5)


func _draw_outline(
		vertices: PackedVector2Array, color_: Color, width: float
) -> void:
	var radius: float = width * 0.5
	draw_circle(vertices[0], radius, color_)
	for i in range(1, vertices.size()):
		draw_line(vertices[i - 1], vertices[i], color_, width)
		draw_circle(vertices[i], radius, color_)
	draw_line(vertices[vertices.size() - 1], vertices[0], color_, width)


func mouse_is_inside_shape() -> bool:
	var mouse_position_in_world: Vector2 = (
			PositionScreenToWorld.new()
			.result(get_viewport().get_mouse_position(), get_viewport())
	)
	var local_mouse_position: Vector2 = (
			mouse_position_in_world - global_position
	)
	return Geometry2D.is_point_in_polygon(local_mouse_position, polygon)


func highlight_selected() -> void:
	_outline_type = OutlineType.SELECTED


func highlight(is_target: bool) -> void:
	if is_target:
		_outline_type = OutlineType.HIGHLIGHT_TARGET
	else:
		_outline_type = OutlineType.HIGHLIGHT


func remove_highlight() -> void:
	_outline_type = OutlineType.NONE


func _on_owner_changed(province: Province) -> void:
	if province.owner_country != null:
		color = province.owner_country.color
	else:
		color = Color.WHITE
