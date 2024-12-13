class_name ProvinceHighlight
extends Node
## Adds or removes highlight on given [Province] and its links.

@export var provinces_container: ProvinceVisualsContainer2D

var armies: Armies
var playing_country: PlayingCountry
var armies_in_each_province: ArmiesInEachProvince


func _on_province_selected(province: Province) -> void:
	var active_armies: Array[Army] = (
			armies_in_each_province
			.dictionary[province].list.duplicate()
	)
	for army: Army in active_armies.duplicate():
		if not (
				army.owner_country == playing_country.country()
				and army.is_able_to_move()
		):
			active_armies.erase(army)

	# NOTE assumes countries only ever have one active army per province
	var has_active_army: bool = active_armies.size() > 0
	var army: Army = active_armies[0] if has_active_army else null

	for link_visuals in provinces_container.links_of(province):
		link_visuals.highlight_shape(
				has_active_army and army.can_move_to(link_visuals.province)
		)


func _on_province_deselected(province: Province) -> void:
	for link_visuals in provinces_container.links_of(province):
		link_visuals.remove_highlight()
