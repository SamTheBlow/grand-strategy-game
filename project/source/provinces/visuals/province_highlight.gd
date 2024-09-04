class_name ProvinceHighlight
extends Node
## Adds or removes highlight on given [Province] and its links.


@export var provinces_container: ProvinceVisualsContainer2D

var armies: Armies
var playing_country: PlayingCountry


func _on_province_selected(province: Province) -> void:
	# NOTE assumes countries only ever have one active army per province
	var active_armies: Array[Army] = (
			armies.active_armies(playing_country.country(), province)
	)
	var has_active_army: bool = active_armies.size() > 0
	var army: Army = active_armies[0] if has_active_army else null
	
	for link_visuals in provinces_container.links_of(province):
		link_visuals.highlight_shape(
				has_active_army and army.can_move_to(link_visuals.province)
		)


func _on_province_deselected(province: Province) -> void:
	for link_visuals in provinces_container.links_of(province):
		link_visuals.remove_highlight()
