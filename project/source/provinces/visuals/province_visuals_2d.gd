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

@onready var _outlined_polygon := %Polygon as OutlinedPolygon2D
@onready var _collision_shape := %CollisionShape as CollisionPolygon2D
@onready var _buildings := %Buildings as BuildingVisuals2D
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
	debug_highlight.polygon = province.polygon().array
	debug_highlight.outline_settings = outline_settings
	add_child(debug_highlight)


func _update_province() -> void:
	if not is_node_ready():
		return

	if province == null:
		push_error("Province is null.")
		name = "NullProvince"
		return

	name = str(province.id)
	position = Vector2.ZERO
	scale = Vector2.ONE

	_army_stack.position = province.position_army_host
	_buildings.setup(province)

	_update_polygon()
	_update_shape_color()
	remove_highlight()

	province.polygon().changed.connect(_update_polygon)


func _update_polygon() -> void:
	if is_preview:
		_update_preview()

	_outlined_polygon.polygon = province.polygon().array
	_collision_shape.polygon = province.polygon().array


func _update_shape_color() -> void:
	_outlined_polygon.color = (
			province.owner_country.color
			if province.owner_country != null else _default_shape_color
	)


func _update_preview() -> void:
	# Get the boundaries
	var no_data: bool = true
	var leftmost_point: float
	var rightmost_point: float
	var topmost_point: float
	var bottommost_point: float

	for vertex in province.polygon().array:
		# Initialization
		if no_data:
			leftmost_point = vertex.x
			rightmost_point = vertex.x
			topmost_point = vertex.y
			bottommost_point = vertex.y
			no_data = false
			continue

		if vertex.x < leftmost_point:
			leftmost_point = vertex.x
		elif vertex.x > rightmost_point:
			rightmost_point = vertex.x
		if vertex.y < topmost_point:
			topmost_point = vertex.y
		elif vertex.y > bottommost_point:
			bottommost_point = vertex.y

	if no_data:
		return

	var province_rect := Rect2(
			leftmost_point,
			topmost_point,
			rightmost_point - leftmost_point,
			bottommost_point - topmost_point
	)

	# Prevent division by zero
	if province_rect.size.x == 0.0 or province_rect.size.y == 0.0:
		return

	# Determine the scale ratio (e.g. if the province
	# is 3x bigger than it should be, then we need to scale by 1/3)
	# To preserve the aspect ratio,
	# we need to multiply by the smallest of the two ratios.
	var scale_ratio: float = minf(
			preview_rect.size.x / province_rect.size.x,
			preview_rect.size.y / province_rect.size.y
	)
	position = (
			preview_rect.position + 0.5 * preview_rect.size
			- scale_ratio * (province_rect.position + 0.5 * province_rect.size)
	)
	scale = Vector2(scale_ratio, scale_ratio)


func _connect_signals() -> void:
	if province == null:
		return

	if not province.owner_changed.is_connected(_on_owner_changed):
		province.owner_changed.connect(_on_owner_changed)
	if not province.position_army_host_changed.is_connected(
			_on_position_army_host_changed
	):
		province.position_army_host_changed.connect(
				_on_position_army_host_changed
		)


func _disconnect_signals() -> void:
	if province == null:
		return

	if province.owner_changed.is_connected(_on_owner_changed):
		province.owner_changed.disconnect(_on_owner_changed)
	if province.position_army_host_changed.is_connected(
			_on_position_army_host_changed
	):
		province.position_army_host_changed.disconnect(
				_on_position_army_host_changed
		)


func _on_owner_changed(_province: Province) -> void:
	_update_shape_color()


func _on_position_army_host_changed(new_position: Vector2) -> void:
	_army_stack.position = new_position


func _on_shape_unhandled_mouse_event_occured(event: InputEventMouse) -> void:
	unhandled_mouse_event_occured.emit(event, self)


func _on_mouse_entered() -> void:
	mouse_entered.emit()


func _on_mouse_exited() -> void:
	mouse_exited.emit()
