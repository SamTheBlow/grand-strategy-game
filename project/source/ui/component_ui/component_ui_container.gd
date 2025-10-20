class_name ComponentUIContainer
extends Node
## Creates, holds and deletes a [ComponentUI]
## on the currently selected province.

signal button_pressed(button_id: int)
signal country_button_pressed(country: Country)

const _COMPONENT_UI_SCENE := preload("uid://btp4jcvpp4jg2") as PackedScene

var _is_setup: bool = false
var _game: Game
var _province_container: ProvinceVisualsContainer2D
var _province_selection: ProvinceSelection

## The child node, for easy access. May be null.
var _component_ui: ComponentUI
var _province_visuals: ProvinceVisuals2D


func _ready() -> void:
	if _is_setup:
		_update()


func setup(
		game: Game,
		province_container: ProvinceVisualsContainer2D,
		province_selection: ProvinceSelection
) -> void:
	if _is_setup and is_node_ready():
		_disconnect_signals()

	_game = game
	_province_container = province_container
	_province_selection = province_selection

	_is_setup = true
	
	if is_node_ready():
		_update()


func _update() -> void:
	_connect_signals()


func _create_ui(province_visuals: ProvinceVisuals2D) -> void:
	_component_ui = _COMPONENT_UI_SCENE.instantiate() as ComponentUI
	_component_ui.setup(_game, province_visuals)

	_component_ui.button_pressed.connect(button_pressed.emit)
	_component_ui.country_button_pressed.connect(country_button_pressed.emit)

	_province_visuals = province_visuals
	_province_visuals.tree_exiting.connect(_destroy_ui)

	add_child(_component_ui)


func _destroy_ui() -> void:
	if _component_ui == null:
		return

	remove_child(_component_ui)
	_component_ui.queue_free()

	_province_visuals.tree_exiting.disconnect(_destroy_ui)
	_province_visuals = null

	_component_ui.button_pressed.disconnect(button_pressed.emit)
	_component_ui.country_button_pressed.disconnect(country_button_pressed.emit)

	_component_ui = null


func _connect_signals() -> void:
	_province_selection.selected_province_changed.connect(
			_on_selected_province_changed
	)


func _disconnect_signals() -> void:
	_province_selection.selected_province_changed.connect(
			_on_selected_province_changed
	)


func _on_selected_province_changed(province: Province) -> void:
	_destroy_ui()
	if province == null:
		return
	var province_visuals: ProvinceVisuals2D = (
			_province_container.visuals_of(province.id)
	)
	if province_visuals != null:
		_create_ui(province_visuals)
