class_name RelationshipPresetLabelUpdate
extends Node
## Updates the information displayed on a [RelationshipPresetLabel].


@export var label: RelationshipPresetLabel

var is_relationship_presets_enabled: bool:
	set(value):
		is_relationship_presets_enabled = value
		_refresh()

var country: Country:
	set(value):
		country = value
		_refresh()

var country_to_relate_to: Country:
	set(value):
		country_to_relate_to = value
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	
	if (
			not is_relationship_presets_enabled
			or not country
			or not country_to_relate_to
			or country == country_to_relate_to
	):
		label.relationship = null
		return
	
	label.relationship = (
			country.relationships.with_country(country_to_relate_to)
	)
