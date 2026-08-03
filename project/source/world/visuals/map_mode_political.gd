class_name MapModePolitical
extends Node
## Highlights the links of currently selected [Province].
## This is the normal usual map mode.

## This node has no effect when disabled.
var is_enabled: bool = false:
	set(value):
		if is_enabled == value:
			return
		is_enabled = value
		if _armies != null and is_node_ready():
			refresh_highlights()

var _armies: Armies
var _provinces: Provinces
var _playing_country: PlayingCountry
var _armies_in_each_province: ArmiesInEachProvince
var _province_selection: ProvinceSelection

var _highlighted_province_link_ids: Array[int] = []

@onready var _province_container := %Provinces as ProvinceVisualsContainer2D


func setup(
		armies: Armies,
		provinces: Provinces,
		playing_country: PlayingCountry,
		armies_in_each_province: ArmiesInEachProvince,
		province_selection: ProvinceSelection
) -> void:
	_armies = armies
	_provinces = provinces
	_playing_country = playing_country
	_armies_in_each_province = armies_in_each_province
	_province_selection = province_selection
	_province_selection.province_selected.connect(_highlight_links)
	_province_selection.province_deselected.connect(_clear_highlights.unbind(1))

	if is_node_ready():
		refresh_highlights()
	else:
		ready.connect(refresh_highlights, ConnectFlags.CONNECT_ONE_SHOT)


## Highlights selected province's links.
func refresh_highlights() -> void:
	_clear_highlights()
	_highlight_links(_province_selection.selected_province())


func _highlight_links(province: Province) -> void:
	if province == null or not is_enabled:
		return

	# Highlight all the linked provinces with the correct highlight type

	var active_armies: Array[Army] = (
			_armies_in_each_province.in_province(province).list.duplicate()
	)
	for army: Army in active_armies.duplicate():
		if not (
				army.owner_country == _playing_country.country()
				and army.is_able_to_move()
		):
			active_armies.erase(army)

	# NOTE assumes countries only ever have one active army per province
	var has_active_army: bool = active_armies.size() > 0
	var army: Army = active_armies[0] if has_active_army else null

	for link_id in province.linked_province_ids():
		var link_visuals: ProvinceVisuals2D = (
				_province_container.visuals_of(link_id)
		)
		if link_visuals == null:
			continue

		if has_active_army and army.can_move_to(_provinces, link_id):
			link_visuals.highlight_target()
		else:
			link_visuals.highlight()

	_highlighted_province_link_ids = province.linked_province_ids().duplicate()


func _clear_highlights() -> void:
	for province_link_id in _highlighted_province_link_ids:
		var province_visuals: ProvinceVisuals2D = (
				_province_container.visuals_of(province_link_id)
		)
		if province_visuals != null:
			province_visuals.remove_highlight()

	_highlighted_province_link_ids.clear()
