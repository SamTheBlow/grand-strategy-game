class_name DecorationVisuals2D
extends Node2D
## A [WorldDecoration]'s visuals for a 2D world map.
## Handles input (hover & clicking) when input is enabled.

signal clicked()
signal mouse_entered()
signal mouse_exited()

## If true, this decoration will eat inputs and emit input-related signals.
@export var is_input_enabled: bool = false:
	set(value):
		is_input_enabled = value
		if is_node_ready():
			_refresh_input_filter()

@export_group("Outline types")
## Outline used when no other outline is used.
@export var _outline_none: OutlineSettings
## Outline used to highlight the decoration (e.g. when hovering it).
@export var _outline_highlight: OutlineSettings
## Outline used when the decoration is selected (e.g. while editing it).
@export var _outline_selected: OutlineSettings

var world_decoration: WorldDecoration

@onready var _sprite := %DecorationSprite as Sprite2D
@onready var _control := %Control as Control
@onready var _outline := %DecorationOutline as OutlinedPolygon2D


func _ready() -> void:
	# Give this node a unique meaningful name
	name = "Decoration" + str(world_decoration.get_instance_id())

	_refresh_input_filter()

	_control.mouse_entered.connect(mouse_entered.emit)
	_control.mouse_exited.connect(mouse_exited.emit)

	_refresh_visuals()
	world_decoration.changed.connect(_refresh_visuals.unbind(1))


## When clicked, emits signal and eats input
func _unhandled_input(event: InputEvent) -> void:
	if not is_input_enabled:
		return
	if event is not InputEventMouseButton:
		return
	var event_mouse_button := event as InputEventMouseButton
	if event_mouse_button.button_index != MOUSE_BUTTON_LEFT:
		return
	if event_mouse_button.pressed:
		return

	if get_viewport().gui_get_hovered_control() != _control:
		return

	get_viewport().set_input_as_handled()
	clicked.emit()


## Shows an outline around this decoration.
func highlight() -> void:
	_outline.outline_settings = _outline_highlight


## Shows a stronger outline around this decoration.
func highlight_selected() -> void:
	_outline.outline_settings = _outline_selected
	_control.grab_focus(true)


## Hides the outline around this decoration.
func remove_highlight() -> void:
	_outline.outline_settings = _outline_none


func _refresh_input_filter() -> void:
	if is_input_enabled:
		_control.focus_mode = Control.FOCUS_ALL
		_control.mouse_filter = Control.MOUSE_FILTER_PASS
	else:
		_control.focus_mode = Control.FOCUS_NONE
		_control.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Applies the decoration's data to the visuals.
func _refresh_visuals() -> void:
	_sprite.texture = world_decoration.texture.texture(
			WorldDecoration.DEFAULT_TEXTURE
	)
	_sprite.flip_h = world_decoration.flip_h
	_sprite.flip_v = world_decoration.flip_v
	position = world_decoration.position
	_sprite.rotation_degrees = world_decoration.rotation_degrees
	_sprite.scale = world_decoration.scale
	_sprite.modulate = world_decoration.color

	_refresh_control_size()
	_refresh_outline_size()


## The axis-aligned size of the sprite, in this node's local coordinates.
func _sprite_size() -> Vector2:
	return _sprite.scale * (
			Vector2(_sprite.texture.get_width(), _sprite.texture.get_height())
	)


## Makes the input area match the sprite's bounding box.
func _refresh_control_size() -> void:
	_control.size = _sprite_size()
	_control.position = -0.5 * _control.size


## Makes the outline match the sprite's bounding box.
func _refresh_outline_size() -> void:
	var half_size: Vector2 = 0.5 * _sprite_size()
	_outline.polygon = PackedVector2Array([
			Vector2(-half_size.x, -half_size.y),
			Vector2(half_size.x, -half_size.y),
			Vector2(half_size.x, half_size.y),
			Vector2(-half_size.x, half_size.y),
	])
