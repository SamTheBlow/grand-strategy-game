class_name ArmyVisuals2D
extends Node2D
## An [Army]'s visuals for a 2D world map.

var army: Army:
	set(value):
		army = value

		# Give this node a unique meaningful name
		name = "Army" + str(army.id)

		army.allegiance_changed.connect(_refresh_army_color)
		army.size().changed.connect(_refresh_army_size)

		army.province_changed.connect(_on_army_province_changed)
		army.moved_to_province.connect(_on_army_moved_to_province)
		army.movements_made_changed.connect(_on_army_movements_made_changed)

## Stops animations and updates tint when the playing country changes.
var playing_country: PlayingCountry:
	set(value):
		playing_country = value
		playing_country.changed.connect(_on_playing_country_changed)

@onready var _animation := %MovementAnimation as ArmyMovementAnimation2D
@onready var _army_sprite := %ArmySprite as Sprite2D
@onready var _army_size_box := %ArmySizeBox as ArmySizeBox


func _ready() -> void:
	_refresh_army_color()
	_refresh_army_size()

	if army.size().maximum_value == 1:
		_army_size_box.hide()

	_animation.is_playing_changed.connect(_on_animation_is_playing_changed)
	_refresh_brightness()


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


func _refresh_army_color(_owner_country: Country = null) -> void:
	if not is_node_ready():
		return

	_army_sprite.modulate = army.owner_country.color
	_army_size_box.color = army.owner_country.color


func _refresh_army_size(_new_army_size: int = 0) -> void:
	if not is_node_ready():
		return

	_army_size_box.number = army.size().value


## Darkens the visuals if the army cannot perform any action.
func _refresh_brightness() -> void:
	if not is_node_ready():
		return

	var brightness: float = 1.0
	var current_playing_country: Country = (
			playing_country.country() if playing_country != null else null
	)

	if not (
			army.is_able_to_move()
			or current_playing_country != army.owner_country
			or _animation.is_playing()
	):
		brightness = 0.5

	modulate = Color(brightness, brightness, brightness)


func _on_army_province_changed(_army: Army) -> void:
	if _animation != null and get_parent() != null:
		_animation.original_global_position = global_position


func _on_army_moved_to_province(_province: Province) -> void:
	if _animation != null:
		_animation.play()


## Darken the visuals when the army can no longer perform an action.
func _on_army_movements_made_changed(_movements_made: int) -> void:
	_refresh_brightness()


## When it's another country's turn, prematurely end the movement animation.
## Don't darken the visuals when it's another country's turn.
## Do darken them if it's your turn.
func _on_playing_country_changed(_country: Country) -> void:
	if _animation != null:
		_animation.stop()

	_refresh_brightness()


## Don't darken the visuals when an animation plays.
## Do darken them after the animation is over.
func _on_animation_is_playing_changed(_is_playing: bool) -> void:
	_refresh_brightness()
