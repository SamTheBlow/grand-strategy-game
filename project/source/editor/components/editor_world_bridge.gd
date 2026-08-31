class_name EditorWorldBridge
extends Node
## Bridges the game world and the editing interface.
# TODO turn ProvinceSelection into a Node and then get rid of this script

signal selected_province_changed(province: Province)

@export var _world_visuals: WorldVisuals2D


## Note: we do it like this because ProvinceSelection
## is replaced with a new instance each time a world is loaded.
func connect_province_selection(world_visuals: WorldVisuals2D) -> void:
	world_visuals.province_selection.selected_province_changed.connect(
			selected_province_changed.emit
	)


func _on_province_interface_opened(province: Province) -> void:
	_world_visuals.province_selection.select(province)


func _on_province_interface_closed() -> void:
	_world_visuals.province_selection.deselect()


func _on_country_interface_opened(country: Country) -> void:
	_world_visuals.province_selection.is_disabled = true
	_world_visuals.province_link_highlighter.is_enabled = false
	_world_visuals.show_arrows_of_country(country)


func _on_country_interface_closed() -> void:
	_world_visuals.province_selection.is_disabled = false
	_world_visuals.province_link_highlighter.is_enabled = true
	_world_visuals.show_game_arrows()
