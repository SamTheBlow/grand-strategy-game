class_name ProvincePreviewNode
extends Control

const _PROVINCE_VISUALS_SCENE := preload("uid://cppfb8jwghnqt") as PackedScene

var _province_visuals: ProvinceVisuals2D


func _ready() -> void:
	if _province_visuals != null:
		add_child(_province_visuals)


func setup(province: Province) -> void:
	_province_visuals = (
			_PROVINCE_VISUALS_SCENE.instantiate() as ProvinceVisuals2D
	)
	_province_visuals.province = province
	_province_visuals.is_preview = true
	_province_visuals.preview_rect = Rect2(Vector2.ZERO, size)
	if is_node_ready():
		add_child(_province_visuals)
