class_name AutoArrowsNode2D
extends Node2D
## A list of [AutoArrowNode2D].
## There is one such list for each [Country].
## It automatically shows or hides itself when the right conditions are met.
##
## See also: [AutoArrow]


## This list represents this country's arrows.
var _country: Country

var _list: Array[AutoArrowNode2D] = []

## If any of these flags is turned on, this node will be hidden
## 1: No province is selected
## 2: The currently playing player's country doesn't match this list's country
var _visible_flags: int = 3:
	set(value):
		_visible_flags = value
		visible = _visible_flags == 0


## This node listens to changes in the game's state to update itself.
## But, it cannot know the initial state of the game.
## So we have to provide the initial state manually.
## This function also connects the signals.
func init(game: Game, country_: Country) -> void:
	_country = country_
	
	_on_selected_province_changed(game.world.provinces.selected_province)
	game.world.provinces.selected_province_changed.connect(
		_on_selected_province_changed
	)
	_on_player_turn_changed(game.turn.playing_player())
	game.turn.player_changed.connect(_on_player_turn_changed)
	_country.auto_arrows.arrow_added.connect(_on_arrow_added)


func add(auto_arrow_node: AutoArrowNode2D) -> void:
	add_child(auto_arrow_node)
	_list.append(auto_arrow_node)
	auto_arrow_node.removed.connect(_on_arrow_removed)


func remove(auto_arrow: AutoArrow) -> void:
	for node in _list:
		if node.auto_arrow == null:
			continue
		if node.auto_arrow.is_equivalent_to(auto_arrow):
			_remove_node(node)
			return
	push_warning(
			"Tried removing an AutoArrow, but it had no corresponding node."
	)


func country() -> Country:
	return _country


func _remove_node(auto_arrow_node: AutoArrowNode2D) -> void:
	if not _list.has(auto_arrow_node):
		push_warning(
				"Tried removing an AutoArrow node, but it wasn't on the list."
		)
		return
	remove_child(auto_arrow_node)
	_list.erase(auto_arrow_node)


func _on_arrow_added(auto_arrow: AutoArrow) -> void:
	var auto_arrow_node := AutoArrowNode2D.new()
	auto_arrow_node.auto_arrow = auto_arrow
	add(auto_arrow_node)


func _on_arrow_removed(auto_arrow_node: AutoArrowNode2D) -> void:
	_remove_node(auto_arrow_node)


func _on_selected_province_changed(province: Province) -> void:
	if province:
		_visible_flags &= ~1
	else:
		_visible_flags |= 1


func _on_player_turn_changed(playing_player: GamePlayer) -> void:
	if playing_player.playing_country == _country:
		_visible_flags &= ~2
	else:
		_visible_flags |= 2
