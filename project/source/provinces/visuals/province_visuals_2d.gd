class_name ProvinceVisuals2D
extends Node2D
## Visual representation of a [Province].

signal mouse_entered()
signal mouse_exited()

signal unhandled_mouse_event_occured(
		event: InputEventMouse, this: ProvinceVisuals2D
)

@export_group("Outline types")
## Outline used when no other outline is used.
@export var _outline_none: OutlineSettings
## Outline used when the province is selected.
@export var _outline_selected: OutlineSettings
## Outline used to highlight the province.
@export var _outline_highlight: OutlineSettings
## Outline used to show the province as a valid target.
@export var _outline_target: OutlineSettings

var province: Province:
	set(value):
		_disconnect_signals()
		province = value
		_connect_signals()
		_update_province()

## When true, changes the position and scale
## such that the province fits inside given preview_rect.
var is_preview: bool = false
var preview_rect: Rect2

var _preview_polygon: PackedVector2Array = []
var _preview_position := Vector2.ZERO

@onready var _buildings_setup := %BuildingVisualsSetup as BuildingVisualsSetup

@onready var _outlined_polygon := %Polygon as OutlinedPolygon2D
@onready var _collision_shape := %CollisionShape as CollisionPolygon2D

@onready var _army_stack := %ArmyStack2D as ArmyStack2D

## The color defined in the editor will be the default color
## when the province doesn't have a valid owner country.
@onready var _default_shape_color: Color = _outlined_polygon.color


func _ready() -> void:
	_update_province()


func add_army(army_visuals: ArmyVisuals2D) -> void:
	if not is_node_ready():
		push_error("Node is not ready yet.")
		return
	if army_visuals.get_parent() != null:
		push_error("Army visuals already have a parent node.")
		return
	_army_stack.add_child(army_visuals)


func highlight_selected() -> void:
	_outlined_polygon.outline_settings = _outline_selected


func highlight_shape(is_target: bool) -> void:
	_outlined_polygon.outline_settings = (
			_outline_target if is_target else _outline_highlight
	)


func remove_highlight() -> void:
	_outlined_polygon.outline_settings = _outline_none


## Returns the global army host position.
func global_position_army_host() -> Vector2:
	return to_global(province.position_army_host)


## Debug function that clearly highlights this province on the world map.
## To remove the highlight, pass false as an argument.
func highlight_debug(
		outline_color: Color = Color.BLUE, show_highlight: bool = true
) -> void:
	if has_node("DebugHighlight"):
		remove_child(get_node("DebugHighlight"))

	if not show_highlight:
		return

	var outline_settings := OutlineSettings.new()
	outline_settings.outline_color = outline_color
	outline_settings.outline_width = 8.0

	var debug_highlight := OutlinedPolygon2D.new()
	debug_highlight.name = "DebugHighlight"
	debug_highlight.color = Color(0.0, 0.0, 0.0, 0.0)
	debug_highlight.polygon = _polygon()
	debug_highlight.outline_settings = outline_settings
	add_child(debug_highlight)


func _update_province() -> void:
	if not is_node_ready():
		return

	if province == null:
		push_error("Province is null.")
		name = "NullProvince"
		return

	if is_preview:
		_calculate_preview()

	name = str(province.id)
	position = _position()
	_update_positions()

	_buildings_setup.province = province
	_buildings_setup.buildings = province.buildings

	_update_polygon()
	_update_shape_color()
	remove_highlight()

	province.polygon().changed.connect(_update_polygon)


func _update_positions() -> void:
	_army_stack.position = province.position_army_host


func _update_polygon() -> void:
	if is_preview:
		_calculate_preview()
		position = _preview_position

	_outlined_polygon.polygon = _polygon()
	_collision_shape.polygon = _polygon()


func _update_shape_color() -> void:
	_outlined_polygon.color = (
			province.owner_country.color
			if province.owner_country != null else _default_shape_color
	)


func _calculate_preview() -> void:
	var polygon: PackedVector2Array = province.polygon().array

	# Get the boundaries
	var no_data: bool = true
	var leftmost_point: float
	var rightmost_point: float
	var topmost_point: float
	var bottommost_point: float

	for vertex in polygon:
		var point_x: float = vertex.x
		var point_y: float = vertex.y

		# Initialization
		if no_data:
			leftmost_point = point_x
			rightmost_point = point_x
			topmost_point = point_y
			bottommost_point = point_y
			no_data = false
			continue

		if point_x < leftmost_point:
			leftmost_point = point_x
		elif point_x > rightmost_point:
			rightmost_point = point_x
		if point_y < topmost_point:
			topmost_point = point_y
		elif point_y > bottommost_point:
			bottommost_point = point_y

	if no_data:
		return

	var width: float = rightmost_point - leftmost_point
	var height: float = bottommost_point - topmost_point
	var desired_width: float = preview_rect.size.x
	var desired_height: float = preview_rect.size.y

	# Prevent division by zero
	if (
			width == 0.0
			or height == 0.0
			or desired_width == 0.0
			or desired_height == 0.0
	):
		return

	# Multiply every vertex by the scale ratio
	# (e.g. if the polygon is 3x bigger than it should be,
	# then multiply every vertex by 1/3)
	# To preserve the aspect ratio,
	# we need to multilply by the smallest of the two ratios.
	# Then offset every vertex to move the polygon to the desired position.
	var scale_ratio: float = (
			minf(desired_width / width, desired_height / height)
	)
	var offset := Vector2(
			preview_rect.position.x - leftmost_point,
			preview_rect.position.y - topmost_point
	)
	_preview_polygon = []
	for i in polygon.size():
		_preview_polygon.append((polygon[i] + offset) * scale_ratio)
	_preview_position = (
			0.5 * (preview_rect.size - Vector2(width, height) * scale_ratio)
	)


func _polygon() -> PackedVector2Array:
	return _preview_polygon if is_preview else province.polygon().array


func _position() -> Vector2:
	return _preview_position if is_preview else Vector2.ZERO


func _connect_signals() -> void:
	if province == null:
		return

	if not province.owner_changed.is_connected(_on_owner_changed):
		province.owner_changed.connect(_on_owner_changed)
	if not province.position_changed.is_connected(_on_position_changed):
		province.position_changed.connect(_on_position_changed)


func _disconnect_signals() -> void:
	if province == null:
		return

	if province.owner_changed.is_connected(_on_owner_changed):
		province.owner_changed.disconnect(_on_owner_changed)
	if province.position_changed.is_connected(_on_position_changed):
		province.position_changed.disconnect(_on_position_changed)


func _on_owner_changed(_province: Province) -> void:
	_update_shape_color()


func _on_position_changed() -> void:
	_update_positions()


func _on_shape_unhandled_mouse_event_occured(event: InputEventMouse) -> void:
	unhandled_mouse_event_occured.emit(event, self)


func _on_mouse_entered() -> void:
	mouse_entered.emit()


func _on_mouse_exited() -> void:
	mouse_exited.emit()
