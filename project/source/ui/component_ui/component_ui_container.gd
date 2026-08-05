class_name ComponentUIContainer
extends Node
## Creates, holds and deletes a [ComponentUI] on currently selected province.

signal button_pressed(button_id: int)
signal country_button_pressed(country: Country)

const _COMPONENT_UI_SCENE: PackedScene = preload("uid://btp4jcvpp4jg2")

## The child node, for easy access. May be null.
var _component_ui: ComponentUI = null

## We need to store this to disconnect its signal later. May be null.
var _province_visuals: ProvinceVisuals2D = null


func setup(
		game: Game,
		province_container: ProvinceVisualsContainer2D,
		province_selection: ProvinceSelection
) -> void:
	province_selection.selected_province_changed.connect(
			_refresh.bind(game, province_container)
	)


func _refresh(
		province: Province,
		game: Game,
		province_container: ProvinceVisualsContainer2D
) -> void:
	_destroy_ui()

	if province == null:
		return

	var visuals: ProvinceVisuals2D = province_container.visuals_of(province.id)
	if visuals == null:
		return

	var component_ui := _COMPONENT_UI_SCENE.instantiate() as ComponentUI
	component_ui.setup(game, visuals)
	component_ui.button_pressed.connect(button_pressed.emit)
	component_ui.country_button_pressed.connect(country_button_pressed.emit)
	add_child(component_ui)
	_component_ui = component_ui

	_province_visuals = visuals
	_province_visuals.tree_exiting.connect(_destroy_ui)


func _destroy_ui() -> void:
	if _component_ui == null:
		return

	_province_visuals.tree_exiting.disconnect(_destroy_ui)
	_province_visuals = null

	_component_ui.button_pressed.disconnect(button_pressed.emit)
	_component_ui.country_button_pressed.disconnect(country_button_pressed.emit)
	NodeUtils.delete_node(_component_ui)
	_component_ui = null
