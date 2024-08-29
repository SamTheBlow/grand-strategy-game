extends Node
## Updates a given [ProvinceShapePolygon2D] using given [ProvinceVisuals2D].


@export var _province_shape: ProvinceShapePolygon2D
@export var _province_visuals: ProvinceVisuals2D


func _ready() -> void:
	if not _province_shape:
		push_error("Province shape is null.")
		return
	if not _province_visuals:
		push_error("Province is null.")
		return
	
	_province_visuals.province.owner_changed.connect(
			_province_shape._on_owner_changed
	)
	_province_shape._on_owner_changed(_province_visuals.province)
