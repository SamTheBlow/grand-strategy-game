class_name ProvinceHighlight
extends Node
## Adds or removes highlight on the selected [Province] and its links.

var _is_setup: bool = false
var _armies: Armies
var _playing_country: PlayingCountry
var _armies_in_each_province: ArmiesInEachProvince
var _province_selection: ProvinceSelection

var _highlighted_province_id: int = -1
var _highlighted_province_link_ids: Array[int] = []

@onready var _province_container := %Provinces as ProvinceVisualsContainer2D


func _ready() -> void:
	if _is_setup:
		_update()


func setup(
		armies: Armies,
		playing_country: PlayingCountry,
		armies_in_each_province: ArmiesInEachProvince,
		province_selection: ProvinceSelection
) -> void:
	if _is_setup and is_node_ready():
		_disconnect_signals()

	_armies = armies
	_playing_country = playing_country
	_armies_in_each_province = armies_in_each_province
	_province_selection = province_selection

	_highlighted_province_id = -1
	_highlighted_province_link_ids = []

	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	_highlight_province(_province_selection.selected_province())
	_connect_signals()


func _highlight_province(province: Province) -> void:
	if province == null:
		return

	# Highlight the province
	var province_visuals: ProvinceVisuals2D = (
			_province_container.visuals_of(province.id)
	)
	if province_visuals != null:
		province_visuals.highlight_selected()

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
		link_visuals.highlight_shape(
				has_active_army and army.can_move_to(link_visuals.province)
		)

	_highlighted_province_id = province.id
	_highlighted_province_link_ids = province.linked_province_ids().duplicate()


func _remove_highlights() -> void:
	_remove_highlight(_highlighted_province_id)
	_highlighted_province_id = -1
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
	_province_selection.province_selected.disconnect(_highlight_province)
	_province_selection.province_deselected.disconnect(_on_province_deselected)


func _connect_signals() -> void:
	_province_selection.province_selected.connect(_highlight_province)
	_province_selection.province_deselected.connect(_on_province_deselected)


func _on_province_deselected(_province: Province) -> void:
	_remove_highlights()
