@tool
class_name ListContainer
extends Control
## Container that automatically adjusts the position and size of
## its children such that they are aligned horizontally.
## It's similar to the [HBoxContainer].


## If true, uses node_width_absolute and ignores node_width_ratio.
## Otherwise, uses node_width_ratio and ignores node_width_absolute.
@export var is_width_absolute: bool = false:
	set(value):
		is_width_absolute = value
		_update_layout()

## The horizontal space to give to each child, as a ratio of width/height.
## For example, 1.0 would make a square,
## and 2.0 would make the width twice as long as the height.
@export var node_width_ratio: float = 1.0:
	set(value):
		node_width_ratio = value
		_update_layout()

## The horizontal space to give to each child, in pixels.
@export var node_width_absolute: float = 64.0:
	set(value):
		node_width_absolute = value
		_update_layout()

## The horizontal space to add in-between each child, in pixels.
@export var spacing: float = 2.0:
	set(value):
		spacing = value
		_update_layout()

## If true, aligns its children from right to left. Otherwise, left to right.
@export var is_right_to_left: bool = false:
	set(value):
		is_right_to_left = value
		_update_layout()


func _ready() -> void:
	child_order_changed.connect(_update_layout)
	resized.connect(_update_layout)
	_update_layout()


func _update_layout() -> void:
	if not is_node_ready():
		return
	
	var node_width: float = (
			node_width_absolute
			if is_width_absolute else
			size.y * node_width_ratio
	)
	
	var offset_x: float = (size.x - node_width) if is_right_to_left else 0.0
	for child in get_children():
		if not child is Control:
			continue
		var control := child as Control
		
		if not control.visibility_changed.is_connected(_update_layout):
			control.visibility_changed.connect(_update_layout)
		
		if not control.visible:
			continue
		
		# Prevent an editor warning
		control.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		
		control.size = Vector2(node_width, size.y)
		control.position.x = position.x + offset_x
		
		offset_x += (
				(node_width + spacing) * (-1.0 if is_right_to_left else 1.0)
		)
