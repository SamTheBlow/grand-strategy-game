class_name ProvinceVisualsContainer2D
extends Node2D
## An encapsulated list of [ProvinceVisuals2D].

# TODO these signals are ugly and confusing
signal province_selected(province_visuals: ProvinceVisuals2D)
signal province_mouse_entered(province_visuals: ProvinceVisuals2D)
signal province_mouse_exited(province_visuals: ProvinceVisuals2D)
signal unhandled_mouse_event_occured(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
)

const _PROVINCE_VISUALS_SCENE := preload("uid://cppfb8jwghnqt") as PackedScene

## A list of all the child nodes, for easy access.
var _list: Array[ProvinceVisuals2D] = []

## Maps a province id to its visuals, for performance reasons.
var _province_map: Dictionary[int, ProvinceVisuals2D] = {}


## No effect if the province already has visuals.
func add_province(province: Province) -> void:
	if _province_map.has(province.id):
		return

	var province_visuals := (
			_PROVINCE_VISUALS_SCENE.instantiate() as ProvinceVisuals2D
	)
	province_visuals.province = province

	_list.append(province_visuals)
	_province_map[province.id] = province_visuals

	province_visuals.unhandled_mouse_event_occured.connect(
			unhandled_mouse_event_occured.emit
	)
	province_visuals.mouse_entered.connect(
			province_mouse_entered.emit.bind(province_visuals)
	)
	province_visuals.mouse_exited.connect(
			province_mouse_exited.emit.bind(province_visuals)
	)

	add_child(province_visuals)


## No effect if the province didn't have visuals.
func remove_province(province: Province) -> void:
	if not _province_map.has(province.id):
		return
	var province_visuals: ProvinceVisuals2D = _province_map[province.id]
	_province_map.erase(province.id)
	_list.erase(province_visuals)
	remove_child(province_visuals)
	province_visuals.queue_free()


## Removes all province visuals.
func clear() -> void:
	NodeUtils.remove_all_children(self)
	_list = []
	_province_map = {}


## Returns null if given province doesn't have visuals.
func visuals_of(province_id: int) -> ProvinceVisuals2D:
	if _province_map.has(province_id):
		return _province_map[province_id]
	return null


## Returns the visuals for each of given [Province]'s linked provinces.
func links_of(province: Province) -> Array[ProvinceVisuals2D]:
	var output: Array[ProvinceVisuals2D] = []
	for linked_province_id in province.linked_province_ids():
		output.append(_province_map[linked_province_id])
	return output


func _on_province_selected(province: Province) -> void:
	if not _province_map.has(province.id):
		return
	var visuals: ProvinceVisuals2D = _province_map[province.id]
	visuals.select()
	province_selected.emit(visuals)


func _on_province_deselected(province: Province) -> void:
	if not _province_map.has(province.id):
		return
	var visuals: ProvinceVisuals2D = _province_map[province.id]
	visuals.deselect()


func _on_preview_arrow_created(preview_arrow: AutoArrowPreviewNode2D) -> void:
	# TODO bad code: private function
	province_mouse_entered.connect(preview_arrow._on_province_mouse_entered)
	province_mouse_exited.connect(preview_arrow._on_province_mouse_exited)
