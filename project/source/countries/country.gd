class_name Country
extends Resource
## Represents a political entity. It is called "country", but in truth,
## this can represent any political entity, even those who do not
## have control over any land.

signal money_changed(new_amount: int)

const DEFAULT_COLOR := Color.WHITE

@export var country_name: String = ""
@export var color: Color = DEFAULT_COLOR

## Unique identifier. Useful for saving/loading, networking, etc.
var id: int = -1

var money: int = 0:
	set(value):
		money = value
		money_changed.emit(money)

var relationships: DiplomacyRelationships

var notifications := GameNotifications.new()

var auto_arrows := AutoArrows.new()


## Returns true if this country's armies have the
## diplomatic permission to move into given country's provinces.
## Also returns true if you're trespassing.
func can_move_into_country(country: Country) -> bool:
	return (
			has_permission_to_move_into_country(country)
			or self.relationships.with_country(country).is_trespassing()
	)


## Returns true if this country's armies have the
## diplomatic permission to move into given country's provinces.
func has_permission_to_move_into_country(country: Country) -> bool:
	return (
			country == self
			or country == null
			or
			country.relationships.with_country(self).grants_military_access()
	)


## Returns true if the two given countries are fighting each other.
static func is_fighting(country_1: Country, country_2: Country) -> bool:
	return (
			country_1 != country_2
			and (
					country_1.relationships
					.with_country(country_2).is_fighting()
					or
					country_2.relationships
					.with_country(country_1).is_fighting()
			)
	)


## Returns a list of all the countries that are
## neighboring this country on the world map.
## The returned list may contain null, in which case
## this country neighbors unclaimed land.
## The returned list has no duplicates.
func neighboring_countries(
		provinces_of_country: ProvincesOfCountry,
		provinces: Provinces
) -> Array[Country]:
	var list_of_neighbors: Array[Country] = []
	for owned_province: Province in provinces_of_country.list:
		for linked_province_id in owned_province.linked_province_ids():
			var linked_province: Province = (
					provinces.province_from_id(linked_province_id)
			)
			if linked_province == null:
				push_error("Linked province is null.")
				continue

			var neighbor: Country = linked_province.owner_country
			if neighbor != self and not neighbor in list_of_neighbors:
				list_of_neighbors.append(neighbor)
	return list_of_neighbors


## Similar to neighboring_countries, but takes military access into account.
## So if you can reach a country by going through another country,
## it will also be included in this list.
## This is a superset of neighboring_countries.
## (All neighboring countries are guaranteed to be in this list.)
## May contain null. Has no duplicates.
func reachable_countries(
		provinces_of_country: ProvincesOfCountry, provinces: Provinces
) -> Array[Country]:
	var reachable_countries_list: Array[Country] = []
	for frontline_province in provinces.provinces_on_frontline(self):
		for linked_province_id in frontline_province.linked_province_ids():
			var linked_province: Province = (
					provinces.province_from_id(linked_province_id)
			)
			if linked_province == null:
				push_error("Linked province is null.")
				continue

			var reachable_country: Country = linked_province.owner_country
			if (
					reachable_country != self
					and not reachable_country in reachable_countries_list
			):
				reachable_countries_list.append(reachable_country)

	for neighbor in neighboring_countries(provinces_of_country, provinces):
		if not neighbor in reachable_countries_list:
			reachable_countries_list.append(neighbor)

	return reachable_countries_list


## Returns this instance parsed to a raw dictionary.
func to_raw_dict() -> Dictionary:
	return CountryParsing.country_to_raw_dict(self)
