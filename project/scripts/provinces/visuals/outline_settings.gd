class_name OutlineSettings
extends Resource
## Defines the settings for an outline (a visible outline around some shape).


@export var is_outline_enabled: bool = true:
	set(value):
		if is_outline_enabled == value:
			return
		
		is_outline_enabled = value
		changed.emit()

@export var outline_color := Color.WEB_GRAY:
	set(value):
		if outline_color == value:
			return
		
		outline_color = value
		changed.emit()

@export var outline_width: float = 10.0:
	set(value):
		if outline_width == value:
			return
		
		outline_width = value
		changed.emit()
