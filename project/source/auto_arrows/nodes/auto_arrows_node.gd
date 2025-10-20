class_name AutoArrowsNode2D
extends Node2D
## A list of [AutoArrowNode2D]. Visual representation of given [AutoArrows].
## Automatically shows or hides itself when the right conditions are met.
##
## See also: [AutoArrow]

var auto_arrows := AutoArrows.new():
	set(value):
		auto_arrows = value
		_update()

var province_visuals_container: ProvinceVisualsContainer2D

var _list: Array[AutoArrowNode2D] = []

## If any of these flags is turned on, this node will be hidden
## 1: No province is selected
## 2: The currently playing country doesn't have control over the autoarrows
var _visible_flags: int = 0b11:
	set(value):
		_visible_flags = value
		visible = _visible_flags == 0


func _ready() -> void:
	_update()


## This node listens to changes in the game's state to update itself.
## But, it cannot know the initial state of the game.
## So we have to provide the initial state manually.
## This function also connects the signals.
func init(
		playing_country: PlayingCountry, province_selection: ProvinceSelection
) -> void:
	_on_selected_province_changed(province_selection.selected_province())
	province_selection.selected_province_changed.connect(
			_on_selected_province_changed
	)

	_on_playing_country_changed(playing_country.country())
	playing_country.changed.connect(_on_playing_country_changed)


func _update() -> void:
	if not is_node_ready():
		return

	# Disconnect signals
	if auto_arrows.arrow_added.is_connected(_add):
		auto_arrows.arrow_added.disconnect(_add)
	if auto_arrows.arrow_removed.is_connected(_remove):
		auto_arrows.arrow_removed.disconnect(_remove)

	# Clear list
	NodeUtils.remove_all_children(self)
	_list = []

	# Initialize list
	for auto_arrow in auto_arrows.list():
		_add(auto_arrow)

	# Connect signals
	auto_arrows.arrow_added.connect(_add)
	auto_arrows.arrow_removed.connect(_remove)


## No effect if given arrow doesn't refer to existing provinces,
## or if the source province is not linked to the destination.
func _add(auto_arrow: AutoArrow) -> void:
	var source_province_visuals: ProvinceVisuals2D = (
			province_visuals_container
			.visuals_of(auto_arrow.source_province_id())
	)
	if source_province_visuals == null:
		return
	var destination_province_visuals: ProvinceVisuals2D = (
			province_visuals_container
			.visuals_of(auto_arrow.destination_province_id())
	)
	if destination_province_visuals == null:
		return
	if (
			not source_province_visuals.province
			.is_linked_to(destination_province_visuals.province.id)
	):
		return

	var auto_arrow_node := AutoArrowNode2D.new()
	auto_arrow_node.source_province = source_province_visuals
	auto_arrow_node.destination_province = destination_province_visuals
	_add_node(auto_arrow_node)


func _remove(auto_arrow: AutoArrow) -> void:
	for node in _list:
		if node.auto_arrow().is_equivalent_to(auto_arrow):
			_remove_node(node)
			return

	push_warning(
			"Tried removing an AutoArrow, but it had no corresponding node."
	)


func _add_node(auto_arrow_node: AutoArrowNode2D) -> void:
	if _list.has(auto_arrow_node):
		push_warning(
				"Tried adding an AutoArrowNode2D, "
				+ "but it was already on the list."
		)
		return

	add_child(auto_arrow_node)
	_list.append(auto_arrow_node)


func _remove_node(auto_arrow_node: AutoArrowNode2D) -> void:
	if not _list.has(auto_arrow_node):
		push_warning(
				"Tried removing an AutoArrow node, but it wasn't on the list."
		)
		return

	remove_child(auto_arrow_node)
	_list.erase(auto_arrow_node)


func _on_selected_province_changed(province: Province) -> void:
	if province == null:
		_visible_flags |= 1
	else:
		_visible_flags &= ~1


func _on_playing_country_changed(new_playing_country: Country) -> void:
	if (
			new_playing_country == null
			or new_playing_country.auto_arrows != auto_arrows
	):
		_visible_flags |= 2
	else:
		_visible_flags &= ~2
