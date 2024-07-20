class_name CountryRelationshipNode
extends Control
## Interface that displays information about a
## [DiplomacyRelationship] between two countries.
##
## Note: if either country_1 or country_2 is null, this node will hide itself.


var country_1: Country:
	set(value):
		country_1 = value
		_refresh()

var country_2: Country:
	set(value):
		country_2 = value
		_refresh()

var is_diplomatic_presets_enabled: bool = false

@onready var _container := %Container as Control
@onready var _preset := %Preset as RelationshipInfoNode
@onready var _grants_military_access_info := (
		%GrantsMilitaryAccessInfo as RelationshipInfoNode
)
@onready var _is_trespassing_info := (
		%IsTrespassingInfo as RelationshipInfoNode
)
@onready var _is_fighting_info := (
		%IsFightingInfo as RelationshipInfoNode
)

func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	
	if country_1 == null or country_2 == null:
		hide()
		return
	
	var relationship: DiplomacyRelationship = (
			country_1.relationships.with_country(country_2)
	)
	var reverse_relationship: DiplomacyRelationship = (
			country_2.relationships.with_country(country_1)
	)
	
	if is_diplomatic_presets_enabled:
		_preset.country_1 = country_1
		_preset.country_2 = country_2
		_preset.info_text_1_to_2 = relationship.preset().name
		_preset.info_color_1_to_2 = relationship.preset().color
		_preset.info_text_2_to_1 = reverse_relationship.preset().name
		_preset.info_color_2_to_1 = reverse_relationship.preset().color
		_preset.show()
	else:
		_preset.hide()
	
	_populate_relationship_info_bool(
			_grants_military_access_info,
			relationship.grants_military_access(),
			reverse_relationship.grants_military_access()
	)
	_populate_relationship_info_bool(
			_is_trespassing_info,
			relationship.is_trespassing(),
			reverse_relationship.is_trespassing()
	)
	_populate_relationship_info_bool(
			_is_fighting_info,
			relationship.is_fighting(),
			reverse_relationship.is_fighting()
	)
	
	show()
	_update_minimum_height()


func _update_minimum_height() -> void:
	# 64 is to take the left/right margins into account (32px each)
	var minimum_height: float = 64
	
	var number_of_controls: int = 0
	for node in _container.get_children():
		if not node is Control:
			continue
		var control := node as Control
		if not control.visible:
			continue
		number_of_controls += 1
		minimum_height += control.custom_minimum_size.y
	
	# Take node spacing into account
	if number_of_controls > 1:
		minimum_height += (number_of_controls - 1) * 4
	
	custom_minimum_size.y = minimum_height


func _populate_relationship_info_bool(
		info_node: RelationshipInfoNode, value: bool, reverse_value: bool
) -> void:
	info_node.country_1 = country_1
	info_node.country_2 = country_2
	info_node.info_text_1_to_2 = "Yes" if value else "No"
	info_node.info_color_1_to_2 = Color.GREEN if value else Color.RED
	info_node.info_text_2_to_1 = "Yes" if reverse_value else "No"
	info_node.info_color_2_to_1 = Color.GREEN if reverse_value else Color.RED
