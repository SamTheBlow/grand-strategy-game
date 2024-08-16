class_name ScaledLabel
extends Label
## A [Label] that scales its text by given amount.


## The node to use as reference for scaling the text.[br]
## The text will be scaled to a given percentage of this node's height.
@export var anchor_node: Control:
	set(value):
		anchor_node = value
		_refresh()

## Percentage of the anchor node's vertical size.[br]
## Values outside of 0% - 100% are not recommended.
@export_custom(PROPERTY_HINT_NONE, "suffix:%") var text_scale: float = 80.0:
	set(value):
		text_scale = value
		_refresh()


func _ready() -> void:
	_refresh()
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _refresh() -> void:
	if not is_node_ready() or anchor_node == null:
		return
	
	var new_font_size: int = floori(anchor_node.size.y * text_scale * 0.01)
	set("theme_override_font_sizes/font_size", new_font_size)


func _on_viewport_size_changed() -> void:
	_refresh()
