extends Node
## Applies decoration visibility setting to given container node.

@export var _setting: ItemBool
@export var _decorations_container: Node2D


func _ready() -> void:
	_decorations_container.visible = _setting.value
	_setting.value_changed.connect(_set_visibility)


func _set_visibility(value: bool) -> void:
	_decorations_container.visible = value
