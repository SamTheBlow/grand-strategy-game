class_name RelationshipPresetLabelUpdate
extends Node
## Sets the [DiplomacyRelationship] used for given [RelationshipPresetLabel].

@export var label: RelationshipPresetLabel

var is_disabled: bool = false:
	set(value):
		is_disabled = value
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
			is_disabled
			or country == null
			or country_to_relate_to == null
			or country == country_to_relate_to
	):
		label.relationship = null
		return

	label.relationship = (
			country.relationships.with_country(country_to_relate_to)
	)
