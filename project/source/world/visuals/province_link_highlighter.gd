class_name ProvinceLinkHighlighter
extends Node
## Highlights the links of currently selected [Province].

## This node has no effect when disabled.
var is_enabled: bool = true:
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

var _province_selection: ProvinceSelection:
	set(value):
		if _province_selection != null:
			_province_selection.province_selected.disconnect(_highlight_links)
			_province_selection.province_deselected.disconnect(
					_clear_highlights
			)

		_province_selection = value

		_province_selection.province_selected.connect(_highlight_links)
		_province_selection.province_deselected.connect(
				_clear_highlights.unbind(1)
		)


var _highlighted_province_link_ids: Array[int] = []

@onready var _province_container := %Provinces as ProvinceVisualsContainer2D


## Highlights selected province's links.
func refresh_highlights() -> void:
	_clear_highlights()
	_highlight_links(_province_selection.selected_province)


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


func _on_world_loaded(world_visuals: WorldVisuals2D) -> void:
	_armies = world_visuals.world.armies
	_provinces = world_visuals.world.provinces
	_playing_country = world_visuals.playing_country
	_armies_in_each_province = world_visuals.world.armies_in_each_province
	_province_selection = world_visuals.province_selection

	if is_node_ready():
		refresh_highlights()
	else:
		ready.connect(refresh_highlights, ConnectFlags.CONNECT_ONE_SHOT)
