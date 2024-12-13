class_name CountryInfoPopup
extends VBoxContainer
## Displays information about given [Country].
##
## See also: [GamePopup]

@export var _country_and_relationship_scene: PackedScene
@export var _country_relationship_scene: PackedScene

var game_node: GameNode:
	set(value):
		game_node = value
		_connect_relationship_info_signal()
		_connect_relationship_with_player_signal()
		_populate_countries()

var country: Country:
	set(value):
		country = value
		_refresh()

var _relationship_info: CountryRelationshipNode:
	set(value):
		if _relationship_info != null:
			_relationship_info.queue_free()
		_disconnect_relationship_info_signal()
		_relationship_info = value
		_connect_relationship_info_signal()
		_update_country_list_height()

@onready var _header := %Header as CountryAndRelationship
@onready var _money_label := %Money as Label
@onready var _relationship_with_player := (
		%RelationshipWithPlayer as CountryRelationshipNode
)
@onready var _country_list := %CountryList as Control
@onready var _countries := %Countries as Control


func _ready() -> void:
	_connect_relationship_with_player_signal()
	_refresh()


func buttons() -> Array[String]:
	return ["Close"]


func _refresh() -> void:
	if game_node == null or country == null or not is_node_ready():
		return
	var game: Game = game_node.game

	var playing_country: Country = game.turn.playing_player().playing_country

	_header.country = country
	_header.country_to_relate_to = playing_country
	_header.is_relationship_presets_disabled = (
			not game.rules.is_diplomacy_presets_enabled()
	)

	_money_label.text = "Money: $" + str(country.money)

	_relationship_with_player.country_1 = playing_country
	_relationship_with_player.country_2 = country
	_relationship_with_player.game = game

	_populate_countries()


func _disconnect_relationship_info_signal() -> void:
	if game_node == null or _relationship_info == null:
		return

	# TODO bad code: private function (6 occurences)
	if _relationship_info.diplomacy_action_pressed.is_connected(
			game_node._on_diplomacy_action_pressed
	):
		_relationship_info.diplomacy_action_pressed.disconnect(
				game_node._on_diplomacy_action_pressed
		)


func _connect_relationship_info_signal() -> void:
	if game_node == null or _relationship_info == null:
		return

	if not _relationship_info.diplomacy_action_pressed.is_connected(
			game_node._on_diplomacy_action_pressed
	):
		_relationship_info.diplomacy_action_pressed.connect(
				game_node._on_diplomacy_action_pressed
		)


func _connect_relationship_with_player_signal() -> void:
	if game_node == null or _relationship_with_player == null:
		return

	if not _relationship_with_player.diplomacy_action_pressed.is_connected(
			game_node._on_diplomacy_action_pressed
	):
		_relationship_with_player.diplomacy_action_pressed.connect(
				game_node._on_diplomacy_action_pressed
		)


func _populate_countries() -> void:
	if country == null or game_node == null or not is_node_ready():
		return
	var game: Game = game_node.game

	NodeUtils.delete_all_children(_countries)

	var spacing := Control.new()
	spacing.custom_minimum_size.y = 24
	_countries.add_child(spacing)

	for other_country in game.countries.list():
		if other_country == country:
			continue

		var relationship_node := (
				_country_and_relationship_scene.instantiate()
				as CountryAndRelationship
		)
		relationship_node.country = other_country
		relationship_node.country_to_relate_to = country
		relationship_node.is_relationship_presets_disabled = (
				not game.rules.is_diplomacy_presets_enabled()
		)
		relationship_node.button_press_outcome = (
				_on_relationship_button_pressed
		)
		_countries.add_child(relationship_node)

	spacing = Control.new()
	spacing.custom_minimum_size.y = 24
	_countries.add_child(spacing)

	_update_country_list_height()


# ATTENTION this function contains a lot of important hard coded values!
## Manually sets the minimum height of the country list
func _update_country_list_height() -> void:
	var number_of_countries: int = game_node.game.countries.size() - 1
	var number_of_spacing_nodes: int = 2

	var total_list_height_px := float(
			# Height of the title (the thing that says "All Relationships")
			48
			# Spacing between the title and contents
			+ 4
			# Spacing between the country nodes (and spacing nodes)
			+ (number_of_countries + number_of_spacing_nodes - 1) * 8
			# Height of the country nodes
			+ number_of_countries * 64
			# Height of the spacing nodes
			+ number_of_spacing_nodes * 24
	)

	if _relationship_info != null:
		total_list_height_px += _relationship_info.size.y

	_country_list.custom_minimum_size.y = minf(384.0, total_list_height_px)


func _on_relationship_button_pressed(button_country: Country) -> void:
	var new_relationship_info := (
			_country_relationship_scene.instantiate()
			as CountryRelationshipNode
	)
	new_relationship_info.country_1 = country
	new_relationship_info.country_2 = button_country
	new_relationship_info.game = game_node.game

	for node in _countries.get_children():
		if not node is CountryAndRelationship:
			continue
		var country_node := node as CountryAndRelationship
		if country_node.country == button_country:
			if (
					_relationship_info != null
					and _relationship_info.country_2 == button_country
			):
				_relationship_info = null
			else:
				country_node.add_sibling(new_relationship_info)
				_relationship_info = new_relationship_info

			break
