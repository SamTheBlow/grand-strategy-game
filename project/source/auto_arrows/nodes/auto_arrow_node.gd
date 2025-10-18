class_name AutoArrowNode2D
extends Node2D
## Visual representation of an [AutoArrow].
## Shows an arrow going from source province to any given position.
## If a destination province is provided, points at it instead.

var source_province: ProvinceVisuals2D:
	set(value):
		if source_province == value:
			return

		source_province = value

		position = source_province.global_position_army_host()

var destination_province: ProvinceVisuals2D:
	set(value):
		if destination_province == value:
			return

		destination_province = value

		if destination_province == null:
			return
		_arrow.position_tip = (
				to_local(destination_province.global_position_army_host())
		)

## Only affects the arrow when destination_province is null.
var global_pointing_position: Vector2:
	set(value):
		if global_pointing_position == value:
			return

		global_pointing_position = value

		if destination_province == null:
			_arrow.position_tip = to_local(global_pointing_position)

var _arrow := Arrow2D.new()


func _ready() -> void:
	add_child(_arrow)


func auto_arrow() -> AutoArrow:
	return AutoArrow.new(
			source_province.province.id, destination_province.province.id
	)
