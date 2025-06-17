class_name WorldDecoration
## A sprite that's displayed at some location on the world map.

const _DEFAULT_TEXTURE: Texture2D = preload("uid://dlk4vjy5lgeuu")

var texture: Texture2D = _DEFAULT_TEXTURE
var flip_h: bool = false
var flip_v: bool = false
var position := Vector2.ZERO
var rotation_degrees: float = 0.0
var scale := Vector2.ONE
var color := Color.WHITE

## We keep the file path in memory to use it in save files
var texture_file_path: String = ""


## Returns a new [Sprite2D] initialized with this decoration's data.
func new_sprite() -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.flip_h = flip_h
	sprite.flip_v = flip_v
	sprite.position = position
	sprite.rotation_degrees = rotation_degrees
	sprite.scale = scale
	sprite.modulate = color
	return sprite


## Takes a [TextureRect] and changes its data to look like this decoration.
func apply_preview(texture_rect: TextureRect) -> void:
	# Position is not applied. Scale is lowered but keeps aspect ratio.
	texture_rect.texture = texture
	texture_rect.flip_h = flip_h
	texture_rect.flip_v = flip_v
	texture_rect.rotation_degrees = rotation_degrees
	texture_rect.scale = scale / maxf(scale.x, scale.y)
	texture_rect.modulate = color
