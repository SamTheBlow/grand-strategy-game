class_name ProvinceVisualsContainer2D
extends Node2D


signal province_selected(province_visuals: ProvinceVisuals2D)

signal province_mouse_entered(province_visuals: ProvinceVisuals2D)
signal province_mouse_exited(province_visuals: ProvinceVisuals2D)

signal unhandled_mouse_event_occured(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
)

## Do not manipulate the array directly!
var list: Array[ProvinceVisuals2D] = []

## Dictionary[Province, ProvinceVisuals2D]
## Maps a province to its visuals, for performance reasons.
## Do not manipulate the dictionary directly!
var visuals_of_province: Dictionary = {}


func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)


## Returns the visuals for each of given [Province]'s linked provinces.
func links_of(province: Province) -> Array[ProvinceVisuals2D]:
	var output: Array[ProvinceVisuals2D] = []
	for linked_province in province.links:
		output.append(visuals_of_province[linked_province])
	return output


func _on_child_entered_tree(node: Node) -> void:
	if node is not ProvinceVisuals2D:
		return

	var province_visuals := node as ProvinceVisuals2D

	list.append(province_visuals)
	visuals_of_province[province_visuals.province] = province_visuals

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
	var visuals: ProvinceVisuals2D = visuals_of_province[province]
	visuals.select()
	province_selected.emit(visuals)


func _on_province_deselected(province: Province) -> void:
	var visuals: ProvinceVisuals2D = visuals_of_province[province]
	visuals.deselect()


func _on_preview_arrow_created(preview_arrow: AutoArrowPreviewNode2D) -> void:
	# TODO bad code: private function
	province_mouse_entered.connect(preview_arrow._on_province_mouse_entered)
	province_mouse_exited.connect(preview_arrow._on_province_mouse_exited)
