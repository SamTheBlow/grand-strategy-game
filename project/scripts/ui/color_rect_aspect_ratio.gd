@tool
extends ColorRect
## Ensures that this ColorRect's size always respects given aspect ratio.


@export var aspect_ratio: float = 1.0:
	set(value):
		aspect_ratio = value
		_update_anchors()


func _ready() -> void:
	_update_anchors()


func _update_anchors() -> void:
	if resized.is_connected(_on_resized):
		resized.disconnect(_on_resized)
	
	anchor_left = 0
	anchor_right = 1.0
	anchor_top = 0
	anchor_bottom = 1.0
	
	if size.x == 0 or size.y == 0:
		resized.connect(_on_resized)
		return
	
	var current_ratio: float = size.x / size.y
	if current_ratio < aspect_ratio:
		var new_anchor_value: float = 0.5 - 0.5 * current_ratio / aspect_ratio
		anchor_top = new_anchor_value
		anchor_bottom = 1.0 - new_anchor_value
	elif current_ratio > aspect_ratio:
		var new_anchor_value: float = 0.5 - 0.5 / current_ratio * aspect_ratio
		anchor_left = new_anchor_value
		anchor_right = 1.0 - new_anchor_value
	
	resized.connect(_on_resized)


func _on_resized() -> void:
	_update_anchors()
