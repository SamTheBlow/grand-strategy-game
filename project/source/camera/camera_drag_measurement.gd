class_name CameraDragMeasurement
extends Node
## Measures how much drag is being applied to the camera in one mouse click.

@export var _camera: Node2D

var _start_position := Vector2.ZERO
var _drag_amount := Vector2.ZERO

@onready var _camera_drag := %CameraDrag as CameraDrag


func _ready() -> void:
	_camera_drag.drag_started.connect(_on_camera_drag_started)
	_camera_drag.drag_ended.connect(_on_camera_drag_ended)


## Returns the distance moved by the camera during the last drag,
## or zero if the camera was never dragged.
func drag_amount() -> Vector2:
	return _drag_amount


func _on_camera_drag_started() -> void:
	_start_position = _camera.global_position


func _on_camera_drag_ended() -> void:
	_drag_amount = _camera.global_position - _start_position
