extends Node
## Updates a given [ProvinceShapePolygon2D] using given [Province].


@export var province_shape: ProvinceShapePolygon2D
@export var province: Province


func _ready() -> void:
	if not province_shape:
		push_error("Province shape is null.")
		return
	if not province:
		push_error("Province is null.")
		return
	
	province.owner_changed.connect(province_shape._on_owner_changed)
	province_shape._on_owner_changed(province)
	province.selected.connect(province_shape._on_selected)
	province.deselected.connect(province_shape._on_deselected)
	for link in province.links:
		link.deselected.connect(province_shape._on_deselected)
