class_name ProvinceBatchRender
extends Node2D
## Draws every province as a single batched canvas item.
##
## This node exists for performance reasons.
## It's meant to improve performance on very large maps.

@export var lod: WorldLOD

## May be null, in which case nothing is rendered.
var provinces: Provinces = null:
	set(value):
		if provinces != null:
			provinces.added.disconnect(queue_redraw)
			provinces.removed.disconnect(queue_redraw)
			for province in provinces.list:
				province.owner_changed.disconnect(queue_redraw)

		provinces = value
		queue_redraw()

		if provinces != null:
			provinces.added.connect(queue_redraw.unbind(1))
			provinces.removed.connect(queue_redraw.unbind(1))
			for province in provinces.list:
				province.owner_changed.connect(queue_redraw.unbind(1))


func _ready() -> void:
	_refresh_visibility()
	lod.changed.connect(_refresh_visibility)


func _draw() -> void:
	const DEFAULT_FILL_COLOR := Color.WHITE

	if provinces == null:
		return

	for province in provinces.list:
		var country: Country = province.owner_country
		var color: Color = (
				DEFAULT_FILL_COLOR if country == null else country.color
		)
		draw_colored_polygon(province.polygon().array, color)


func _refresh_visibility() -> void:
	visible = lod.detail_level <= WorldLOD.DetailLevel.LOW
