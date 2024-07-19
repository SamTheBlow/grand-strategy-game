class_name CountryInfoPopup
extends VBoxContainer
## The popup that displays information about a given [Country].


@export var _country_and_relationship_scene: PackedScene

var game: Game:
	set(value):
		game = value
		_populate_countries()

var country: Country:
	set(value):
		country = value
		_refresh()

@onready var _header := %Header as CountryAndRelationship
@onready var _money_label := %Money as Label
@onready var _countries := %Countries as Control


func _ready() -> void:
	_refresh()


func buttons() -> Array[String]:
	return ["Close"]


func _refresh() -> void:
	if country == null or not is_node_ready():
		return
	
	_header.country = country
	_header.country_to_relate_to = game.turn.playing_player().playing_country
	_header.is_relationship_presets_enabled = (
			game.rules.diplomacy_presets_option.selected != 0
	)
	_money_label.text = "Money: $" + str(country.money)
	
	_populate_countries()


func _populate_countries() -> void:
	if country == null or game == null or not is_node_ready():
		return
	
	# TODO DRY. This isn't the only place where we need to
	# remove all of a node's children... Might want
	# to make a utility class for this
	for node in _countries.get_children():
		_countries.remove_child(node)
		node.queue_free()
	
	var is_relationship_presets_enabled: bool = (
			game.rules.diplomacy_presets_option.selected != 0
	)
	
	for other_country in game.countries.list():
		if other_country == country:
			continue
		
		var relationship_node := (
				_country_and_relationship_scene.instantiate()
				as CountryAndRelationship
		)
		relationship_node.country = other_country
		relationship_node.country_to_relate_to = country
		relationship_node.is_relationship_presets_enabled = (
				is_relationship_presets_enabled
		)
		_countries.add_child(relationship_node)
	
	var n: int = game.countries.size() - 1
	# "48" is the height of the title (the thing that says "All Relationships")
	# "4" and "(n - 1) * 4" are the spacing between the nodes
	# "n * 64" is the height of all the country nodes
	var total_list_height_px := float(48 + 4 + n * 64 + (n - 1) * 4)
	(%CountryList as Control).custom_minimum_size.y = (
			minf(384.0, total_list_height_px)
	)
