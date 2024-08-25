class_name AutoArrowNode2D
extends Node2D
## Visual representation of an [AutoArrow].
## Shows an arrow going from source province to any given position.
## If a destination province is provided, points at it instead.


var arrow_tip_angle: float = deg_to_rad(30.0):
	set(value):
		arrow_tip_angle = value
		queue_redraw()

var arrow_tip_length: float = 50.0:
	set(value):
		arrow_tip_length = value
		queue_redraw()

var arrow_color: Color = Color.GOLD:
	set(value):
		arrow_color = value
		queue_redraw()

var arrow_thickness: float = 8.0:
	set(value):
		arrow_thickness = value
		queue_redraw()


## May be null, in which case you can instead use manually
## given properties "source_province" and "world_destination".
var auto_arrow: AutoArrow = null:
	set(value):
		if auto_arrow == value:
			return
		auto_arrow = value
		queue_redraw()

## When accessed, returns the "auto_arrow" property's
## source province, if it's not null.
var source_province: Province:
	get:
		if auto_arrow:
			return auto_arrow.source_province
		return source_province
	set(value):
		if source_province == value:
			return
		source_province = value
		if auto_arrow == null:
			queue_redraw()

## When accessed, returns the "auto_arrow" property's
## destination province, if it's not null.
var destination_province: Province:
	get:
		if auto_arrow:
			return auto_arrow.destination_province
		return destination_province
	set(value):
		if destination_province == value:
			return
		destination_province = value
		if auto_arrow == null:
			queue_redraw()

## When accessed, returns the "destination_province" property's
## position, if it's not null.
var world_destination: Vector2:
	get:
		if destination_province:
			return destination_province.global_position_army_host()
		return world_destination
	set(value):
		if world_destination == value:
			return
		world_destination = value
		if destination_province == null:
			queue_redraw()


func _draw() -> void:
	draw_line(
			source_province.global_position_army_host(),
			world_destination,
			arrow_color,
			arrow_thickness
	)
	draw_line(
			world_destination,
			world_destination
			- (world_destination - source_province.global_position_army_host())
			.rotated(arrow_tip_angle).normalized() * arrow_tip_length,
			arrow_color,
			arrow_thickness
	)
	draw_line(
			world_destination,
			world_destination
			- (world_destination - source_province.global_position_army_host())
			.rotated(-arrow_tip_angle).normalized() * arrow_tip_length,
			arrow_color,
			arrow_thickness
	)
