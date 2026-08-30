class_name CountryInfoPopup
extends VBoxContainer
## Displays information about given [Country].
##
## See also: [GamePopup]

signal diplomacy_action_requested(
		diplomacy_action: DiplomacyAction, recipient_country: Country
)

const _COUNTRY_AND_REL_SCENE: PackedScene = preload("uid://b7jj51hv4hwqq")
const _RELATIONSHIP_SCENE: PackedScene = preload("uid://de5dhmkfqssk0")

var _game: Game
var _country: Country

## May be null.
var _relationship_info: CountryRelationshipNode = null:
	set(value):
		if _relationship_info != null:
			_relationship_info.diplomacy_action_pressed.disconnect(
					diplomacy_action_requested.emit
			)
			_relationship_info.queue_free()

		_relationship_info = value
		_update_country_list_height()

		if _relationship_info != null:
			_relationship_info.diplomacy_action_pressed.connect(
					diplomacy_action_requested.emit
			)

@onready var _header := %Header as CountryAndRelationship
@onready var _money_label := %Money as Label
@onready var _relationship_with_player := (
		%RelationshipWithPlayer as CountryRelationshipNode
)
@onready var _country_list := %CountryList as Control
@onready var _countries := %Countries as Control


func _ready() -> void:
	_refresh()

	_relationship_with_player.diplomacy_action_pressed.connect(
			diplomacy_action_requested.emit
	)


func setup(game: Game, country: Country) -> void:
	_game = game
	_country = country
	if is_node_ready():
		_refresh()


func buttons() -> Array[String]:
	return ["Close"]


func _refresh() -> void:
	var playing_country: Country = _game.turn.playing_country()

	_header.country = _country
	_header.country_to_relate_to = playing_country

	_money_label.text = "Money: $%s" % _country.money

	_relationship_with_player.country_1 = playing_country
	_relationship_with_player.country_2 = _country
	_relationship_with_player.game = _game

	NodeUtils.delete_all_children(_countries)

	var spacing := Control.new()
	spacing.custom_minimum_size.y = 24
	_countries.add_child(spacing)

	for other_country in _game.countries.list:
		if other_country == _country:
			continue

		var relationship_node := (
				_COUNTRY_AND_REL_SCENE.instantiate() as CountryAndRelationship
		)
		relationship_node.country = other_country
		relationship_node.country_to_relate_to = _country
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
	var number_of_countries: int = _game.countries.list.size() - 1
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
	for node in _countries.get_children():
		if node is not CountryAndRelationship:
			continue
		var country_node := node as CountryAndRelationship

		if country_node.country != button_country:
			continue

		if (
				_relationship_info != null
				and _relationship_info.country_2 == button_country
		):
			_relationship_info = null
		else:
			var new_relationship_info := (
					_RELATIONSHIP_SCENE.instantiate() as CountryRelationshipNode
			)
			new_relationship_info.country_1 = _country
			new_relationship_info.country_2 = button_country
			new_relationship_info.game = _game

			country_node.add_sibling(new_relationship_info)
			_relationship_info = new_relationship_info

		break
