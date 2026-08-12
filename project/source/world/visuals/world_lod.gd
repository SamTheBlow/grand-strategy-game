class_name WorldLOD
extends Node
## Emits a signal when the camera's zoom level passes a certain threshold.

signal changed()

enum DetailLevel {
	# Fully zoomed in - show everything
	HIGHEST = 1024,
	# Mostly zoomed in - hide the smallest details
	HIGH = 768,
	# Somewhat zoomed out - hide small details
	MEDIUM = 512,
	# Quite zoomed out - hide details
	LOW = 256,
	# Fully zoomed out - only show essentials
	LOWEST = 0,
}

var detail_level: DetailLevel = DetailLevel.HIGHEST:
	set(value):
		if detail_level == value:
			return
		detail_level = value
		changed.emit()

@export var _high_threshold: float = 0.7
@export var _medium_threshold: float = 0.4
@export var _low_threshold: float = 0.15
@export var _lowest_threshold: float = 0.05


func _ready() -> void:
	_refresh(get_viewport().get_camera_2d().zoom)


func _refresh(zoom: Vector2) -> void:
	if zoom.x < _lowest_threshold:
		detail_level = DetailLevel.LOWEST
	elif zoom.x < _low_threshold:
		detail_level = DetailLevel.LOW
	elif zoom.x < _medium_threshold:
		detail_level = DetailLevel.MEDIUM
	elif zoom.x < _high_threshold:
		detail_level = DetailLevel.HIGH
	else:
		detail_level = DetailLevel.HIGHEST
