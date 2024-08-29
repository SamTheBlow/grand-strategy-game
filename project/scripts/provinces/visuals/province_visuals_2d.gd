class_name ProvinceVisuals2D
extends Node2D


## See [signal ProvinceShapePolygon2D.unhandled_mouse_event_occured]
signal unhandled_mouse_event_occured(
		event: InputEventMouse, this: ProvinceVisuals2D
)
## See [signal ProvinceShapePolygon2D.mouse_event_occured]
signal mouse_event_occured(event: InputEventMouse, this: ProvinceVisuals2D)

signal selected(this: ProvinceVisuals2D)
signal deselected()

var province: Province:
	set(value):
		_disconnect_signals()
		province = value
		_connect_signals()
		_initialize()

@onready var _shape := %Shape as ProvinceShapePolygon2D
@onready var _army_stack := %ArmyStack2D as ArmyStack2D


func _ready() -> void:
	_initialize()


func add_army(army_visuals: ArmyVisuals2D) -> void:
	if not is_node_ready():
		await ready
	
	if army_visuals.get_parent():
		army_visuals.get_parent().remove_child(army_visuals)
	_army_stack.add_child(army_visuals)


func select() -> void:
	selected.emit(self)
	_shape.highlight_selected()


func deselect() -> void:
	deselected.emit()
	_shape.remove_highlight()


func highlight_shape(is_target: bool) -> void:
	_shape.highlight(is_target)


func remove_highlight() -> void:
	_shape.remove_highlight()


## Returns the global army host position.
func global_position_army_host() -> Vector2:
	return to_global(province.position_army_host)


## Returns the global fortress position.
func global_position_fortress() -> Vector2:
	return to_global(province.position_fortress)


func mouse_is_inside_shape() -> bool:
	return _shape.mouse_is_inside_shape()


## Debug function that clearly highlights this province on the world map.
## To remove the highlight, pass false as an argument.
func highlight_debug(
		outline_color: Color = Color.BLUE, show_highlight: bool = true
) -> void:
	if has_node("DebugHighlight"):
		remove_child(get_node("DebugHighlight"))
	
	if not show_highlight:
		return
	
	var debug_highlight := ProvinceShapePolygon2D.new()
	debug_highlight.name = "DebugHighlight"
	debug_highlight.color = Color(0.0, 0.0, 0.0, 0.0)
	debug_highlight.polygon = _shape.polygon
	debug_highlight.outline_color = outline_color
	debug_highlight._outline_type = (
			ProvinceShapePolygon2D.OutlineType.HIGHLIGHT_TARGET
	)
	add_child(debug_highlight)


func _initialize() -> void:
	if not is_node_ready():
		return
	
	if province == null:
		name = "NullProvince"
		return
	
	name = str(province.id)
	position = province.position
	_shape.polygon = province.polygon
	_army_stack.position = province.position_army_host


func _connect_signals() -> void:
	if province == null or province.game == null:
		return
	
	unhandled_mouse_event_occured.connect(
			province.game._on_province_unhandled_mouse_event
	)
	selected.connect(province.game._on_province_selected)


func _disconnect_signals() -> void:
	if province == null or province.game == null:
		return
	
	unhandled_mouse_event_occured.disconnect(
			province.game._on_province_unhandled_mouse_event
	)
	selected.disconnect(province.game._on_province_selected)


func _on_shape_unhandled_mouse_event_occured(event: InputEventMouse) -> void:
	unhandled_mouse_event_occured.emit(event, self)


func _on_shape_mouse_event_occured(event: InputEventMouse) -> void:
	mouse_event_occured.emit(event, self)
