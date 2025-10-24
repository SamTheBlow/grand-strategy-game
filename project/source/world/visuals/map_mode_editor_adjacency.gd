class_name MapModeEditorAdjacency
extends Node
## Highlights the selected [Province] and its links.
## Adds or removes a right clicked province from the selected province's links.
## Clears selected province's links when double right clicked.

signal overlay_created(node: Node)

## This node has no effect when disabled.
var is_enabled: bool = false:
	set(value):
		if is_enabled == value:
			return
		is_enabled = value
		if _is_setup and is_node_ready():
			if is_enabled:
				_update()
			else:
				_disconnect_signals()

var _is_setup: bool = false
var _province_selection: ProvinceSelection

## May be null.
var _highlighted_province: Province
var _highlighted_province_link_ids: Array[int] = []

## May be null.
var _world_overlay: Node:
	set(value):
		if _world_overlay != null:
			NodeUtils.delete_node(_world_overlay)
		_world_overlay = value
		if _world_overlay != null:
			overlay_created.emit(_world_overlay)

@onready var _province_container := %Provinces as ProvinceVisualsContainer2D


func _ready() -> void:
	if is_enabled and _is_setup:
		_update()


func _exit_tree() -> void:
	# Destroy the overlay
	_world_overlay = null


func setup(
		province_selection: ProvinceSelection
) -> void:
	if is_enabled and _is_setup and is_node_ready():
		_disconnect_signals()

	_province_selection = province_selection

	_highlighted_province = null
	_highlighted_province_link_ids = []

	_is_setup = true

	if is_enabled and is_node_ready():
		_update()


func _update() -> void:
	_province_container.remove_all_highlights()
	_update_selected_province()
	_connect_signals()


func _update_selected_province(_province: Province = null) -> void:
	var selected_province: Province = _province_selection.selected_province()
	if selected_province == null:
		return

	# Add the overlay for polygon editing
	var province_visuals: ProvinceVisuals2D = (
			_province_container.visuals_of(selected_province.id)
	)
	if province_visuals != null:
		var polygon_edit := PolygonEdit.new()
		polygon_edit.polygon = selected_province.polygon()
		polygon_edit.is_draw_polygon_enabled = false
		_world_overlay = polygon_edit

	# Highlight all the linked provinces with the correct highlight type
	for link_id in selected_province.linked_province_ids():
		var link_visuals: ProvinceVisuals2D = (
				_province_container.visuals_of(link_id)
		)
		if link_visuals != null:
			link_visuals.highlight_shape(false)

	_highlighted_province = selected_province
	_highlighted_province_link_ids = (
			selected_province.linked_province_ids().duplicate()
	)

	_highlighted_province.link_added.connect(_on_link_added)
	_highlighted_province.link_removed.connect(_on_link_removed)
	_highlighted_province.links_reset.connect(_on_links_reset)


func _remove_highlights() -> void:
	_world_overlay = null
	_highlighted_province.link_added.disconnect(_on_link_added)
	_highlighted_province.link_removed.disconnect(_on_link_removed)
	_highlighted_province.links_reset.disconnect(_on_links_reset)
	_highlighted_province = null
	_remove_link_highlights()


func _remove_link_highlights() -> void:
	for province_link_id in _highlighted_province_link_ids:
		_remove_highlight(province_link_id)
	_highlighted_province_link_ids = []


func _remove_highlight(province_id: int) -> void:
	var province_visuals: ProvinceVisuals2D = (
			_province_container.visuals_of(province_id)
	)
	if province_visuals != null:
		province_visuals.remove_highlight()


func _disconnect_signals() -> void:
	_province_selection.province_selected.disconnect(_update_selected_province)
	_province_selection.province_deselected.disconnect(_on_province_deselected)


func _connect_signals() -> void:
	_province_selection.province_selected.connect(_update_selected_province)
	_province_selection.province_deselected.connect(_on_province_deselected)


func _on_province_deselected(_province: Province) -> void:
	_remove_highlights()


func _on_link_added(province_id: int) -> void:
	var province_visuals: ProvinceVisuals2D = (
			_province_container.visuals_of(province_id)
	)
	if province_visuals == null:
		return
	province_visuals.highlight_shape(false)
	_highlighted_province_link_ids.append(province_id)


func _on_link_removed(province_id: int) -> void:
	_remove_highlight(province_id)


func _on_links_reset() -> void:
	_remove_link_highlights()


func _on_provinces_unhandled_mouse_event_occured(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
) -> void:
	if not (is_enabled and event is InputEventMouseButton):
		return
	var mouse_button_event := event as InputEventMouseButton

	if not (
			mouse_button_event.pressed
			and mouse_button_event.button_index == MOUSE_BUTTON_RIGHT
	):
		return

	# Double right click the selected province to remove all its links
	if (
			mouse_button_event.double_click
			and province_visuals.province.id
			== _province_selection.selected_province().id
	):
		province_visuals.province.reset_links()

	# Right click a province to toggle
	# whether or not it's linked to the selected province
	_province_selection.selected_province().toggle_link(
			province_visuals.province.id
	)

	get_viewport().set_input_as_handled()
