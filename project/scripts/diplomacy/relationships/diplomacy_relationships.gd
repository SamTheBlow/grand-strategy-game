class_name DiplomacyRelationships
## A list of [DiplomacyRelationship]s.


var _list: Array[DiplomacyRelationship] = []


## Creates a new relationship if there wasn't one before.
## This never returns null.
func with_country(country: Country) -> DiplomacyRelationship:
	for relationship in _list:
		if relationship.recipient_country == country:
			return relationship
	return _new_relationship(country)


func _new_relationship(country: Country) -> DiplomacyRelationship:
	var relationship := DiplomacyRelationship.new()
	relationship.recipient_country = country
	_list.append(relationship)
	return relationship
