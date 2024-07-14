class_name ProvinceShapePolygon2D
extends Polygon2D
## A [Province]'s shape.
## It can draw an outline of your choice around the drawn polygon.
## Emits a signal when the mouse interacts with this shape.
##
## See this page for more info:
## https://godotengine.org/qa/3963/is-it-possible-to-have-a-polygon2d-with-outline


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

@export var province: Province

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


func _ready() -> void:
	if not province:
		push_error("Province shape doesn't have reference to province!")
		return
	
	province.owner_changed.connect(_on_owner_changed)
	_on_owner_changed(province)
	province.selected.connect(_on_selected)
	province.deselected.connect(_on_deselected)
	for link in province.links:
		link.deselected.connect(_on_deselected)


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
		poly: PackedVector2Array,
		ocolor: Color,
		width: float
) -> void:
	var radius: float = width * 0.5
	draw_circle(poly[0], radius, ocolor)
	for i in range(1, poly.size()):
		draw_line(poly[i - 1], poly[i], ocolor, width)
		draw_circle(poly[i], radius, ocolor)
	draw_line(poly[poly.size() - 1], poly[0], ocolor, width)


func mouse_is_inside_shape() -> bool:
	var mouse_position_in_world: Vector2 = (
			PositionScreenToWorld.new()
			.result(get_viewport().get_mouse_position(), get_viewport())
	)
	var local_mouse_position: Vector2 = (
			mouse_position_in_world - global_position
	)
	return Geometry2D.is_point_in_polygon(local_mouse_position, polygon)


func highlight(is_target: bool) -> void:
	if is_target:
		_outline_type = OutlineType.HIGHLIGHT_TARGET
	else:
		_outline_type = OutlineType.HIGHLIGHT


func _on_owner_changed(province_: Province) -> void:
	if province_.owner_country != null:
		color = province_.owner_country.color
	else:
		color = Color.WHITE


func _on_selected() -> void:
	_outline_type = OutlineType.SELECTED


func _on_deselected() -> void:
	_outline_type = OutlineType.NONE
