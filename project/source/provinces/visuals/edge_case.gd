class_name PolygonEditEdgeCase
## Prevents the following edge case.
## If there's only one province on the world map and the world limits
## are set to automatic, then dragging the province shape
## creates an infinite loop of moving the province and moving the camera.

## May be null.
var polygon_edit: PolygonEdit

var _world: GameWorld


func _init(world: GameWorld) -> void:
	_world = world
	_world.limits().mode_changed.connect(_update)
	_world.provinces.added.connect(_on_provinces_changed)
	_world.provinces.removed.connect(_on_provinces_changed)


func _update() -> void:
	if not is_instance_valid(polygon_edit):
		return
	polygon_edit.can_drag_entire_polygon = (
			_world.limits().is_custom_limits_enabled()
			or _world.provinces.size() > 1
	)


func _on_provinces_changed(_province: Province) -> void:
	_update()
