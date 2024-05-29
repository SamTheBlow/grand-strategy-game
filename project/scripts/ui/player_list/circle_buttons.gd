@tool
extends Control
## The circle buttons found in the [PlayerList] and the [TurnOrderList].[br]
## The buttons are positioned on the right side of the box.
## The positions are correctly adjusted even when some buttons are hidden.[br]
## [br]
## To use, add your buttons as children of this node.
## All of this node's children must be of type Control (or a subclass).[br]
## [br]
## NOTE: this node hides itself when it enters the scene tree.
## It's your job to manually make it visible when it's supposed to.


## The space to add between each button, in pixels.
@export var spacing: float = 2.0:
	set(value):
		spacing = value
		_update_layout()


func _ready() -> void:
	hide()
	
	child_order_changed.connect(_on_child_order_changed)
	resized.connect(_on_resized)
	for child in get_children():
		(child as Control).visibility_changed.connect(_update_layout)
	_update_layout()


func _update_layout() -> void:
	var offset_x: float = size.y
	for i in get_children().size():
		var control := get_child(i) as Control
		if not control.visible:
			continue
		
		control.size = Vector2.ONE * size.y
		control.position.x = position.x + size.x - offset_x
		
		offset_x += size.y + spacing


func _on_child_order_changed() -> void:
	_update_layout()


func _on_resized() -> void:
	_update_layout()
