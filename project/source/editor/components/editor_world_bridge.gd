class_name EditorWorldBridge
extends Node
## Bridges the game world and the editing interface.

const _GAME_POPUP_SCENE: PackedScene = preload("uid://by865efl4iwy")
const _COUNTRY_SELECT_POPUP_SCENE: PackedScene = preload("uid://gfcp3xbnck52")

@onready var _editing_interface := %EditingInterface as EditingInterface
@onready var _popup_container := %PopupContainer as Control

var _world_visuals: WorldVisuals2D = null


func _on_world_loaded(world_visuals: WorldVisuals2D) -> void:
	_world_visuals = world_visuals
	_world_visuals.province_selection.selected_province_changed.connect(
			_on_selected_province_changed
	)


func _on_selected_province_changed(province: Province) -> void:
	if province == null:
		_editing_interface.close_interface()
		return
	_editing_interface.open_province_edit_interface(province)


func _on_province_interface_opened(province: Province) -> void:
	_world_visuals.province_selection.select(province)


func _on_province_interface_closed() -> void:
	_world_visuals.province_selection.deselect()


func _on_country_select_pressed(item_country: ItemCountry) -> void:
	# Open popup that lets you choose a country
	var popup := _GAME_POPUP_SCENE.instantiate() as GamePopup
	var country_select_popup := (
			_COUNTRY_SELECT_POPUP_SCENE.instantiate() as CountrySelectPopup
	)
	country_select_popup.setup(
			_world_visuals.project.game.countries, item_country.may_be_null()
	)
	country_select_popup.country_selected.connect(item_country.set_value)
	popup.contents_node = country_select_popup
	_popup_container.add_child(popup)


func _on_country_interface_opened(country: Country) -> void:
	_world_visuals.province_selection.is_disabled = true
	_world_visuals.province_link_highlighter.is_enabled = false
	_world_visuals.show_arrows_of_country(country)


func _on_country_interface_closed() -> void:
	_world_visuals.province_selection.is_disabled = false
	_world_visuals.province_link_highlighter.is_enabled = true
	_world_visuals.show_game_arrows()
