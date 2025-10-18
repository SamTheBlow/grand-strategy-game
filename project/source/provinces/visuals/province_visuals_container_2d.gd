class_name ProvinceVisualsContainer2D
extends Node2D
## Parent node for all of a game's [ProvinceVisuals2D].
# TODO this class is ugly and confusing

signal province_selected(province_visuals: ProvinceVisuals2D)

signal province_mouse_entered(province_visuals: ProvinceVisuals2D)
signal province_mouse_exited(province_visuals: ProvinceVisuals2D)

signal unhandled_mouse_event_occured(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
)

## A list of all the child nodes, for easy access.
var _list: Array[ProvinceVisuals2D] = []

## Maps a province id to its visuals, for performance reasons.
var _province_map: Dictionary[int, ProvinceVisuals2D] = {}


func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)


## Returns null if there are no visuals for given id.
func visuals_of(province_id: int) -> ProvinceVisuals2D:
	if _province_map.has(province_id):
		return _province_map[province_id]
	return null


## Returns the visuals for each of given [Province]'s linked provinces.
func links_of(province: Province) -> Array[ProvinceVisuals2D]:
	var output: Array[ProvinceVisuals2D] = []
	for linked_province in province.links:
		output.append(_province_map[linked_province.id])
	return output


func _on_child_entered_tree(node: Node) -> void:
	if node is not ProvinceVisuals2D:
		return

	var province_visuals := node as ProvinceVisuals2D

	_list.append(province_visuals)
	_province_map[province_visuals.province.id] = province_visuals

	province_visuals.unhandled_mouse_event_occured.connect(
			_on_unhandled_province_mouse_event
	)
	province_visuals.mouse_entered.connect(
			func() -> void: province_mouse_entered.emit(province_visuals)
	)
	province_visuals.mouse_exited.connect(
			func() -> void: province_mouse_exited.emit(province_visuals)
	)


func _on_unhandled_province_mouse_event(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
) -> void:
	unhandled_mouse_event_occured.emit(event, province_visuals)


func _on_province_selected(province: Province) -> void:
	var visuals: ProvinceVisuals2D = _province_map[province.id]
	visuals.select()
	province_selected.emit(visuals)


func _on_province_deselected(province: Province) -> void:
	var visuals: ProvinceVisuals2D = _province_map[province.id]
	visuals.deselect()


func _on_preview_arrow_created(preview_arrow: AutoArrowPreviewNode2D) -> void:
	# TODO bad code: private function
	province_mouse_entered.connect(preview_arrow._on_province_mouse_entered)
	province_mouse_exited.connect(preview_arrow._on_province_mouse_exited)
