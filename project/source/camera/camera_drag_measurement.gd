class_name CameraDragMeasurement
extends Node
## Measures how much drag is being applied to the camera in one mouse click.
## If too much drag was applied, stops propagation of the mouse input.
## This is so that releasing a mouse click after dragging the camera
## doesn't end up clicking on something on the world map.

## In pixels.
const _MAX_DRAG_AMOUNT: float = 30.0

@export var _camera: Node2D
@export var _camera_drag: CameraDrag

var _start_position := Vector2.ZERO


func _ready() -> void:
	_camera_drag.drag_started.connect(_on_camera_drag_started)
	_camera_drag.drag_ended.connect(_on_camera_drag_ended)


func _on_camera_drag_started() -> void:
	_start_position = _camera.global_position


func _on_camera_drag_ended() -> void:
	var drag_amount: Vector2 = _camera.global_position - _start_position
	if (
			absf(drag_amount.x) > _MAX_DRAG_AMOUNT
			or absf(drag_amount.y) > _MAX_DRAG_AMOUNT
	):
		get_viewport().set_input_as_handled()
