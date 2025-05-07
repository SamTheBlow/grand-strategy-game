class_name WorldDecoration
## A sprite that's displayed at some location on the world map.

## Must not be null. (Must be initialized during construction.)
var _texture: Texture2D = null
var _flip_h: bool = false
var _flip_v: bool = false
var _position: Vector2 = Vector2.ZERO
var _rotation_degrees: float = 0.0
var _scale: Vector2 = Vector2.ONE
var _color: Color = Color.WHITE

## We keep the file path in memory to use it in save files
@warning_ignore("unused_private_class_variable")
var _texture_file_path: String = ""


## Returns a new [Sprite2D] initialized with this decoration's data.
func new_sprite() -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = _texture
	sprite.flip_h = _flip_h
	sprite.flip_v = _flip_v
	sprite.position = _position
	sprite.rotation_degrees = _rotation_degrees
	sprite.scale = _scale
	sprite.modulate = _color
	return sprite
