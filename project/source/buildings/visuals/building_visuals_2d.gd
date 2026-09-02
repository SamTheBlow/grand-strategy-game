class_name BuildingVisuals2D
extends Node2D
## Visual representation of a [Building] on a 2D world map.

const FALLBACK_TEXTURE: Texture2D = preload("uid://dlk4vjy5lgeuu")

var building_data: BuildingData

@onready var _sprite := %Sprite2D as Sprite2D


func _ready() -> void:
	_refresh_sprite(building_data.texture)
	building_data.texture_changed.connect(_refresh_sprite.unbind(2))


func _refresh_sprite(project_texture: ProjectTexture) -> void:
	const TARGET_SIZE: float = 64.0

	_sprite.texture = project_texture.texture(FALLBACK_TEXTURE)

	var width := float(_sprite.texture.get_width())
	var height := float(_sprite.texture.get_height())

	var scale_ratio: float = 1.0
	if width != 0.0 and height != 0.0:
		scale_ratio = minf(TARGET_SIZE / width, TARGET_SIZE / height)

	_sprite.scale = Vector2.ONE * scale_ratio
	_sprite.offset.y = -0.5 * height
