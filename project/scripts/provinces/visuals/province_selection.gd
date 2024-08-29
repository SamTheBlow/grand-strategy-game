class_name ProvinceSelection
extends Node


## Emitted when a province is deselected. The given province is never null.
signal province_deselected(province: Province)
## Emitted when a province is selected. The given province is never null.
signal province_selected(province: Province)
## Emitted when the selected_province property
## is assigned a different value (may be null).
signal selected_province_changed(province: Province)

@export var _province_visuals_container: ProvinceVisualsContainer2D

## May be null, in which case no province is selected.
var selected_province: Province:
	set(value):
		if selected_province == value:
			return
		
		if selected_province != null:
			province_deselected.emit(selected_province)
		
		selected_province = value
		
		if selected_province != null:
			province_selected.emit(selected_province)
		
		selected_province_changed.emit(selected_province)


func _ready() -> void:
	province_selected.connect(_on_province_selected)
	province_deselected.connect(_on_province_deselected)


func deselect_province() -> void:
	selected_province = null


func _on_province_selected(province: Province) -> void:
	_province_visuals_container.visuals_of(province).select()
	
	var has_valid_army: bool = false
	var active_armies: Array[Army] = (
			province.game.world.armies.active_armies(
					province.game.turn.playing_player().playing_country,
					province
			)
	)
	var army: Army
	if active_armies.size() > 0:
		army = active_armies[0]
		has_valid_army = true
	
	for link_visuals in _province_visuals_container.links_of(province):
		link_visuals.highlight_shape(
				has_valid_army and army.can_move_to(link_visuals.province)
		)


func _on_province_deselected(province: Province) -> void:
	_province_visuals_container.visuals_of(province).deselect()
	
	for link_visuals in _province_visuals_container.links_of(province):
		link_visuals.remove_highlight()
