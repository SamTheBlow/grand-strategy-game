class_name ArmyVisuals2D
extends Node2D
## An [Army]'s visuals for a 2D world map.
##
## To use, just set the "army" and "playing_country" properties.


signal province_changed(this: ArmyVisuals2D)

## This is meant to be set only once.
var army: Army:
	set(value):
		army = value
		army.province_changed.connect(_on_army_province_changed)
		army.moved_to_province.connect(_on_army_moved_to_province)
		army.movements_made_changed.connect(_on_army_movements_made_changed)
		name = "Army" + str(army.id)

## Stops animations and updates tint when the playing country changes.
var playing_country: PlayingCountry:
	set(value):
		playing_country = value
		playing_country.changed.connect(_on_playing_country_changed)

@onready var _animation := $MovementAnimation as ArmyMovementAnimation2D


func _ready() -> void:
	(%ArmySizeBox as ArmySizeBox).army = army
	_animation.is_playing_changed.connect(_on_animation_is_playing_changed)
	_refresh_brightness()


## To avoid fighting with this node's animations for who gets to move the
## visuals, use this when you want to move the visuals to a new location.
func move_to(new_position: Vector2) -> void:
	# Sets the position anyway so that we can use global_position for the
	# animation and then (if needed) resets the position to what it was before.
	var _old_position: Vector2 = position
	
	position = new_position
	_animation.target_global_position = global_position
	
	if _animation.is_playing():
		position = _old_position


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


# TODO This is called on every single army visuals whenever an army is removed...
# Check how bad this is performance wise, and figure out a better way if needed
func _on_army_removed(removed_army: Army) -> void:
	if removed_army != army:
		return
	
	if get_parent():
		get_parent().remove_child(self)
	queue_free()


func _on_army_province_changed(_army: Army) -> void:
	if get_parent():
		_animation.original_global_position = global_position
	
	province_changed.emit(self)


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
