class_name ArmyVisuals2D
extends Node2D
## An [Army]'s visuals for a 2D world map.

signal clicked()
signal mouse_entered()
signal mouse_exited()

const DEFAULT_TEXTURE: Texture2D = preload("uid://dlk4vjy5lgeuu")

## If true, this army will eat inputs and emit input-related signals.
@export var is_input_enabled: bool = false:
	set(value):
		is_input_enabled = value
		_refresh_input_filter()

@export_group("Outline types")
## Outline used when no other outline is used.
@export var _outline_none: OutlineSettings
## Outline used to highlight the army (e.g. when hovering it).
@export var _outline_highlight: OutlineSettings
## Outline used when the army is selected (e.g. while editing it).
@export var _outline_selected: OutlineSettings

## May be null, in which case LOD culling is disabled.
var lod: WorldLOD = null

var army: Army

## Stops animations and updates tint when the playing country changes.
var playing_country: PlayingCountry

## If true, only renders the outline and disables everything else.
var is_invisible: bool = false

## When true, locks the position and scale
## such that the visuals fit inside given [Control]'s rect.
var is_preview: bool = false
var preview_container: Control

@onready var _animation := %MovementAnimation as ArmyMovementAnimation2D
@onready var _army_sprite := %ArmySprite as Sprite2D
@onready var _control := %Control as Control
@onready var _army_size_box := %ArmySizeBox as ArmySizeBox
@onready var _army_outline := %ArmyOutline as OutlinedPolygon2D


func _ready() -> void:
	if is_invisible:
		_army_sprite.hide()
		_army_size_box.hide()
		_refresh_input_filter()
		return

	# Give this node a unique meaningful name
	name = "Army" + str(army.id)

	_refresh_input_filter()
	_control.mouse_entered.connect(mouse_entered.emit)
	_control.mouse_exited.connect(mouse_exited.emit)

	if lod != null:
		_refresh_visibilities()
		lod.changed.connect(_refresh_visibilities)

	_refresh_army_texture()
	army.texture_changed.connect(_refresh_army_texture)
	_refresh_army_color()
	army.allegiance_changed.connect(_refresh_army_color)
	_refresh_army_size()
	army.size().changed.connect(_refresh_army_size.unbind(1))
	_refresh_animation()
	army.province_changed.connect(_refresh_animation.unbind(1))
	_refresh_brightness()
	army.movements_made_changed.connect(_refresh_brightness.unbind(1))
	playing_country.changed.connect(_refresh_brightness.unbind(1))
	_animation.is_playing_changed.connect(_refresh_brightness.unbind(1))

	if is_preview:
		z_index = 0
		_army_outline.hide()
		_fit_inside_preview_container()
		preview_container.resized.connect(_fit_inside_preview_container)
	else:
		army.moved_to_province.connect(_animation.play.unbind(1))
		# Prematurely end movement animation when playing country changes
		playing_country.changed.connect(_animation.stop.unbind(1))


## To avoid fighting with this node's animations for who gets to move the
## visuals, use this when you want to move the visuals to a new location.
func move_to(new_position: Vector2) -> void:
	if is_preview:
		return

	# Sets the position anyway so that we can use global_position for the
	# animation and then (if needed) resets the position to what it was before.
	var _old_position: Vector2 = position

	position = new_position

	if _animation == null:
		return

	_animation.target_global_position = global_position

	if _animation.is_playing():
		position = _old_position


## Shows an outline around this army.
func highlight() -> void:
	if _army_outline != null:
		_army_outline.outline_settings = _outline_highlight


## Shows a stronger outline around this army.
func highlight_selected() -> void:
	if _army_outline != null:
		_army_outline.outline_settings = _outline_selected
	if is_input_enabled:
		_control.grab_focus(true)


## Hides the outline around this army.
func remove_highlight() -> void:
	if _army_outline != null:
		_army_outline.outline_settings = _outline_none


## Emits clicked when the left mouse button is released on this army.
func _unhandled_input(event: InputEvent) -> void:
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


func _refresh_input_filter() -> void:
	if not is_node_ready():
		return

	if is_input_enabled:
		_control.focus_mode = Control.FOCUS_ALL
		_control.mouse_filter = Control.MOUSE_FILTER_PASS
	else:
		_control.focus_mode = Control.FOCUS_NONE
		_control.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _refresh_visibilities() -> void:
	if is_preview:
		return

	# Size box
	_army_size_box.visible = (
			army.size().maximum_value != 1
			and lod.detail_level > WorldLOD.DetailLevel.MEDIUM
	)

	# Self
	visible = lod.detail_level > WorldLOD.DetailLevel.LOW


func _refresh_army_texture() -> void:
	_army_sprite.texture = army.texture.texture(DEFAULT_TEXTURE)

	var width: float = _army_sprite.texture.get_width()
	var height: float = _army_sprite.texture.get_height()

	var scale_ratio: float = 1.0
	if width != 0.0 and height != 0.0:
		scale_ratio = minf(64.0 / width, 64.0 / height)

	_army_sprite.scale = Vector2.ONE * scale_ratio
	_army_sprite.offset.y = -0.5 * height


func _refresh_army_color() -> void:
	_army_sprite.modulate = army.owner_country.color
	_army_size_box.color = army.owner_country.color


func _refresh_army_size() -> void:
	_army_size_box.number = army.size().value


## Sets the animation's starting position.
func _refresh_animation() -> void:
	_animation.original_global_position = global_position


## Darkens the visuals if the army cannot perform any action.
func _refresh_brightness() -> void:
	var brightness: float = 1.0
	var opacity: float = 1.0

	if not (
			army.is_able_to_move()
			or playing_country.country() != army.owner_country
			or _animation.is_playing()
	):
		brightness = 0.6
		opacity = 0.8

	modulate = Color(brightness, brightness, brightness, opacity)


## Updates position and size to fit this node inside the preview container.
func _fit_inside_preview_container() -> void:
	const ARMY_VISUALS_SIZE := Vector2(64.0, 64.0)

	# Assumes the origin is at the bottom-center of the visuals
	var scale_factor: float = minf(
			preview_container.size.x / ARMY_VISUALS_SIZE.x,
			preview_container.size.y / ARMY_VISUALS_SIZE.y
	)
	position = 0.5 * (
			preview_container.size
			+ Vector2(0.0, ARMY_VISUALS_SIZE.y * scale_factor)
	)
	scale = Vector2.ONE * scale_factor
