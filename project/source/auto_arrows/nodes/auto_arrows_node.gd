class_name AutoArrowsNode2D
extends Node2D
## A list of [AutoArrowNode2D]. Represents given [Country]'s autoarrows.
## Automatically shows or hides itself when the right conditions are met.
##
## See also: [AutoArrow]

## May be null.
var country: Country:
	set(value):
		# Disconnect signals
		if country != null:
			country.auto_arrows.arrow_added.disconnect(_on_arrow_added)
			country.auto_arrows.arrow_removed.disconnect(_on_arrow_removed)

		# Clear list
		for node in _list:
			_remove_node(node)

		country = value
		if country == null:
			return

		# Initialize list
		for auto_arrow in country.auto_arrows.list():
			_add(auto_arrow)

		# Connect signals
		country.auto_arrows.arrow_added.connect(_on_arrow_added)
		country.auto_arrows.arrow_removed.connect(_on_arrow_removed)

var province_visuals_container: ProvinceVisualsContainer2D

## We need this to stay in memory
var _playing_country: PlayingCountry

var _list: Array[AutoArrowNode2D] = []

## If any of these flags is turned on, this node will be hidden
## 1: No province is selected
## 2: The currently playing player's country doesn't match this list's country
var _visible_flags: int = 0b11:
	set(value):
		_visible_flags = value
		visible = _visible_flags == 0


## This node listens to changes in the game's state to update itself.
## But, it cannot know the initial state of the game.
## So we have to provide the initial state manually.
## This function also connects the signals.
func init(
		playing_country: PlayingCountry, province_selection: ProvinceSelection
) -> void:
	_on_selected_province_changed(province_selection.selected_province)
	province_selection.selected_province_changed.connect(
			_on_selected_province_changed
	)

	_playing_country = playing_country
	_on_playing_country_changed(playing_country.country())
	playing_country.changed.connect(_on_playing_country_changed)


func _add(auto_arrow: AutoArrow) -> void:
	var auto_arrow_node := AutoArrowNode2D.new()
	auto_arrow_node.source_province = (
			province_visuals_container
			.visuals_of_province[auto_arrow.source_province]
	)
	auto_arrow_node.destination_province = (
			province_visuals_container
			.visuals_of_province[auto_arrow.destination_province]
	)
	_add_node(auto_arrow_node)


func _remove(auto_arrow: AutoArrow) -> void:
	for node in _list:
		if node.auto_arrow() == null:
			continue

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


func _on_arrow_added(auto_arrow: AutoArrow) -> void:
	_add(auto_arrow)


func _on_arrow_removed(auto_arrow: AutoArrow) -> void:
	_remove(auto_arrow)


func _on_selected_province_changed(province: Province) -> void:
	if province != null:
		_visible_flags &= ~1
	else:
		_visible_flags |= 1


func _on_playing_country_changed(new_playing_country: Country) -> void:
	if new_playing_country == country:
		_visible_flags &= ~2
	else:
		_visible_flags |= 2
