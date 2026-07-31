class_name ArmyVisuals2D
extends Node2D
## An [Army]'s visuals for a 2D world map.

const _DEFAULT_TEXTURE: Texture2D = preload("uid://dlk4vjy5lgeuu")

var army: Army

## Stops animations and updates tint when the playing country changes.
var playing_country: PlayingCountry

@onready var _animation := %MovementAnimation as ArmyMovementAnimation2D
@onready var _army_sprite := %ArmySprite as Sprite2D
@onready var _army_size_box := %ArmySizeBox as ArmySizeBox


func _ready() -> void:
	# Give this node a unique meaningful name
	name = "Army" + str(army.id)

	_refresh_army_texture()
	army.texture_changed.connect(_refresh_army_texture)
	_refresh_army_color()
	army.allegiance_changed.connect(_refresh_army_color.unbind(1))
	_refresh_army_size()
	army.size().changed.connect(_refresh_army_size.unbind(1))
	_refresh_animation()
	army.province_changed.connect(_refresh_animation.unbind(1))
	_refresh_brightness()
	army.movements_made_changed.connect(_refresh_brightness.unbind(1))
	playing_country.changed.connect(_refresh_brightness.unbind(1))
	_animation.is_playing_changed.connect(_refresh_brightness.unbind(1))

	if army.size().maximum_value == 1:
		_army_size_box.hide()

	army.moved_to_province.connect(_animation.play.unbind(1))
	# Prematurely end movement animation when playing country changes
	playing_country.changed.connect(_animation.stop.unbind(1))


## To avoid fighting with this node's animations for who gets to move the
## visuals, use this when you want to move the visuals to a new location.
func move_to(new_position: Vector2) -> void:
	# Sets the position anyway so that we can use global_position for the
	# animation and then (if needed) resets the position to what it was before.
	var _old_position: Vector2 = position

	position = new_position

	if _animation == null:
		return

	_animation.target_global_position = global_position

	if _animation.is_playing():
		position = _old_position


func _refresh_army_texture() -> void:
	_army_sprite.texture = army.texture.texture(_DEFAULT_TEXTURE)

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
