class_name ProvinceVisuals2D
extends Node2D

signal mouse_entered()
signal mouse_exited()

signal unhandled_mouse_event_occured(
		event: InputEventMouse, this: ProvinceVisuals2D
)

signal selected(this: ProvinceVisuals2D)
signal deselected()

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
		await ready

	if army_visuals.get_parent():
		army_visuals.get_parent().remove_child(army_visuals)
	_army_stack.add_child(army_visuals)


func select() -> void:
	_highlight_selected()
	selected.emit(self)


func deselect() -> void:
	remove_highlight()
	deselected.emit()


func _highlight_selected() -> void:
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
	debug_highlight.polygon = province.polygon
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
	position = province.position

	_buildings_setup.buildings = province.buildings
	_buildings_setup.spawn_position = province.position_fortress

	_update_shape_polygon()
	_update_shape_color()
	remove_highlight()

	_army_stack.position = province.position_army_host


func _update_shape_polygon() -> void:
	_outlined_polygon.polygon = province.polygon
	_collision_shape.polygon = province.polygon


func _update_shape_color() -> void:
	_outlined_polygon.color = (
			province.owner_country.color
			if province.owner_country != null else _default_shape_color
	)


func _connect_signals() -> void:
	if province == null:
		return

	if not province.owner_changed.is_connected(_on_owner_changed):
		province.owner_changed.connect(_on_owner_changed)


func _disconnect_signals() -> void:
	if province == null:
		return

	if province.owner_changed.is_connected(_on_owner_changed):
		province.owner_changed.disconnect(_on_owner_changed)


func _on_owner_changed(_province: Province) -> void:
	_update_shape_color()


func _on_shape_unhandled_mouse_event_occured(event: InputEventMouse) -> void:
	unhandled_mouse_event_occured.emit(event, self)


func _on_mouse_entered() -> void:
	mouse_entered.emit()


func _on_mouse_exited() -> void:
	mouse_exited.emit()
