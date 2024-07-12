class_name DiplomacyRelationships
## A list of a country's [DiplomacyRelationship]s.


signal relationship_created(relationship: DiplomacyRelationship)

var _source_country: Country
var _list: Array[DiplomacyRelationship] = []


func _init(country: Country) -> void:
	_source_country = country


## Creates a new relationship if there wasn't one before.
## This never returns null.
func with_country(country: Country) -> DiplomacyRelationship:
	for relationship in _list:
		if relationship.recipient_country == country:
			return relationship
	return _new_relationship(country)


func _new_relationship(country: Country) -> DiplomacyRelationship:
	var relationship := DiplomacyRelationship.new()
	relationship.source_country = _source_country
	relationship.recipient_country = country
	_list.append(relationship)
	relationship_created.emit(relationship)
	return relationship
