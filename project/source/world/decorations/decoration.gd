class_name WorldDecoration
## Represents an image that's displayed at some location on the world map.

signal changed(this: WorldDecoration)

const DEFAULT_TEXTURE: Texture2D = preload("uid://dlk4vjy5lgeuu")

var texture: ProjectTexture = ProjectTexture.none():
	set(value):
		texture = value
		changed.emit(self)

var flip_h: bool = false:
	set(value):
		flip_h = value
		changed.emit(self)

var flip_v: bool = false:
	set(value):
		flip_v = value
		changed.emit(self)

var position := Vector2.ZERO:
	set(value):
		position = value
		changed.emit(self)

var rotation_degrees: float = 0.0:
	set(value):
		rotation_degrees = value
		changed.emit(self)

var scale := Vector2.ONE:
	set(value):
		scale = value
		changed.emit(self)

var color := Color.WHITE:
	set(value):
		color = value
		changed.emit(self)


func texture_2d(project_textures: ProjectTextures) -> Texture2D:
	return texture.texture(project_textures, DEFAULT_TEXTURE)


## Takes a [Sprite2D] and applies this decoration's data to it.
func apply_to_sprite(sprite: Sprite2D, textures: ProjectTextures) -> void:
	sprite.texture = texture_2d(textures)
	sprite.flip_h = flip_h
	sprite.flip_v = flip_v
	sprite.position = position
	sprite.rotation_degrees = rotation_degrees
	sprite.scale = scale
	sprite.modulate = color


## Takes a [TextureRect] and changes its data to look like this decoration.
func apply_preview(
		texture_rect: TextureRect, textures: ProjectTextures
) -> void:
	# Position is not applied. Scale is changed but keeps aspect ratio.
	texture_rect.texture = texture_2d(textures)
	texture_rect.flip_h = flip_h
	texture_rect.flip_v = flip_v
	texture_rect.rotation_degrees = rotation_degrees
	texture_rect.modulate = color

	# The scale is increased or decreased such that it always appears
	# the same size, while also keeping aspect ratio.
	# Also handles negative and zero.
	var absolute_scale: Vector2 = scale.abs()
	var scale_divide_amount: float = maxf(absolute_scale.x, absolute_scale.y)
	texture_rect.scale = (
			absolute_scale / scale_divide_amount
			if scale_divide_amount != 0.0 else Vector2.ONE
	)
