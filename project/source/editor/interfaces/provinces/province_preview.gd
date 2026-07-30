class_name ProvincePreviewNode
extends Control

const _PROVINCE_VISUALS_SCENE := preload("uid://cppfb8jwghnqt") as PackedScene


func setup(province: Province) -> void:
	var visuals := _PROVINCE_VISUALS_SCENE.instantiate() as ProvinceVisuals2D
	visuals.province = province
	visuals.is_preview = true
	visuals.preview_rect = Rect2(Vector2.ZERO, size)
	if is_node_ready():
		add_child(visuals)
	else:
		ready.connect(add_child.bind(visuals), ConnectFlags.CONNECT_ONE_SHOT)
