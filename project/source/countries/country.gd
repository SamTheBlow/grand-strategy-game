class_name Country
## Represents a political entity. It is called "country", but in truth,
## this can represent any political entity, even those who do not
## have control over any land.
##
## Because some extra setup is required before a new instance can be used,
## it's recommended to use Country.Factory to do the setup for you.

signal money_changed(new_amount: int)

const DEFAULT_COLOR := Color.WHITE

## Unique identifier. Useful for saving/loading, networking, etc.
var id: int = -1

var country_name: String = ""

var color: Color = DEFAULT_COLOR

var money: int = 0:
	set(value):
		money = value
		money_changed.emit(money)

## WARNING: this must be manually initialized, requiring a [Game] instance!
var relationships: DiplomacyRelationships

var notifications := GameNotifications.new()

var auto_arrows := AutoArrows.new()


## The default name this instance would have if it didn't have a name.
func default_name() -> String:
	# Let's make these 1-indexed,
	# so the first country is "Country 1" and not "Country 0".
	return "Country " + str(id + 1)


## This instance's name, or its default name if the name is empty.
func name_or_default() -> String:
	if country_name != "":
		return country_name
	else:
		return default_name()


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
		for linked_province in provinces.links_of(owned_province.id):
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
		for linked_province in provinces.links_of(frontline_province.id):
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


## Does the setup required when creating a new instance.
class Factory:
	var _game: Game

	func _init(game: Game) -> void:
		_game = game

	func new_country() -> Country:
		var output := Country.new()
		output.relationships = DiplomacyRelationships.new(_game, output)
		return output
