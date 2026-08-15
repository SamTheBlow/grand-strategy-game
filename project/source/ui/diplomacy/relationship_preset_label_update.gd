class_name RelationshipPresetLabelUpdate
extends Node
## Sets the [DiplomacyRelationship] used for given [RelationshipPresetLabel].

@export var label: RelationshipPresetLabel

## May be null.
var country: Country = null:
	set(value):
		country = value
		_refresh()

## May be null.
var country_to_relate_to: Country = null:
	set(value):
		country_to_relate_to = value
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return

	if (
			country == null
			or country_to_relate_to == null
			or country == country_to_relate_to
	):
		label.relationship = null
		return

	var relationship: DiplomacyRelationship = (
			country.relationships.with_country(country_to_relate_to)
	)
	if relationship.is_preset():
		label.relationship = relationship
	else:
		label.relationship = null
