class_name ArmyVisuals2D
extends Node2D
## An [Army]'s visuals for a 2D world map.
##
## To use, just set the "army" property.
## This node will then be added to the scene tree automatically.
## The visuals will automatically update along with the given [Army].


## This is meant to be set only once.
var army: Army:
	set(value):
		army = value
		army.removed.connect(_on_army_removed)
		army.province_changed.connect(_on_army_province_changed)
		army.moved_to_province.connect(_on_army_moved_to_province)
		army.movements_made_changed.connect(_on_army_movements_made_changed)
		army.game.turn.player_changed.connect(_on_turn_player_changed)
		name = "Army" + str(army.id)
		_add_to_province(army.province())

@onready var _animation := $MovementAnimation as ArmyMovementAnimation2D


func _ready() -> void:
	(%ArmySizeBox as ArmySizeBox).army = army
	_animation.is_playing_changed.connect(_on_animation_is_playing_changed)
	_refresh_brightness()


## To avoid fighting with this node's animations for who gets to move the
## visuals, use this when you want to move the visuals to a new location.
func set_location(new_position: Vector2) -> void:
	_animation.target_position = new_position
	
	if _animation.is_playing():
		return
	
	_animation.original_position = global_position
	global_position = new_position


## Adds this node to the scene tree as a child of a [Province]'s [ArmyStack].
func _add_to_province(province: Province) -> void:
	if get_parent():
		get_parent().remove_child(self)
	if province == null:
		return
	province.army_stack.add_child(self)


## Darkens the visuals if the army cannot perform any action.
func _refresh_brightness() -> void:
	var brightness: float = 1.0
	
	if not (
			army.is_able_to_move()
			or (
					army.game.turn.playing_player().playing_country
					!= army.owner_country
			)
			or _animation.is_playing()
	):
		brightness = 0.5
	
	modulate = Color(brightness, brightness, brightness)


func _on_army_removed() -> void:
	if get_parent():
		get_parent().remove_child(self)
	queue_free()


func _on_army_province_changed(_army: Army, province: Province) -> void:
	_add_to_province(province)


func _on_army_moved_to_province(_province: Province) -> void:
	_animation.play()


## Darken the visuals when the army can no longer perform an action.
func _on_army_movements_made_changed(_movements_made: int) -> void:
	_refresh_brightness()


## When it's a new player's turn, prematurely end the movement animation.
## Don't darken the visuals when it's another player's turn.
## Do darken them if it's your turn.
func _on_turn_player_changed(_player: GamePlayer) -> void:
	_animation.stop()
	_refresh_brightness()


## Don't darken the visuals when an animation plays.
## Do darken them after the animation is over.
func _on_animation_is_playing_changed(_is_playing: bool) -> void:
	_refresh_brightness()
