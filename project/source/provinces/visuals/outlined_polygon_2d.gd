class_name OutlinedPolygon2D
extends Polygon2D
## Draws an outline around its polygon using given [OutlineSettings].

@export var outline_settings: OutlineSettings:
	set(value):
		if outline_settings == value:
			return

		_disconnect_signals()
		outline_settings = value
		_connect_signals()
		queue_redraw()


func _draw() -> void:
	if outline_settings == null or not outline_settings.is_outline_enabled:
		return

	_draw_outline(
			polygon,
			outline_settings.outline_color,
			outline_settings.outline_width
	)


func _draw_outline(
		vertices: PackedVector2Array, outline_color: Color, outline_width: float
) -> void:
	var radius: float = outline_width * 0.5
	draw_circle(vertices[0], radius, outline_color)
	for i in range(1, vertices.size()):
		draw_line(vertices[i - 1], vertices[i], outline_color, outline_width)
		draw_circle(vertices[i], radius, outline_color)
	draw_line(
			vertices[vertices.size() - 1], vertices[0],
			outline_color, outline_width
	)


func _disconnect_signals() -> void:
	if outline_settings == null:
		return

	if outline_settings.changed.is_connected(_on_outline_settings_changed):
		outline_settings.changed.disconnect(_on_outline_settings_changed)


func _connect_signals() -> void:
	if outline_settings == null:
		return

	if not outline_settings.changed.is_connected(_on_outline_settings_changed):
		outline_settings.changed.connect(_on_outline_settings_changed)


func _on_outline_settings_changed() -> void:
	queue_redraw()
