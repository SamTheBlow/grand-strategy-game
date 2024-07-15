class_name Country
extends Resource
## Represents a political entity. It is called "country", but in truth,
## this can represent any political entity, even those who do not
## have control over any land.


signal money_changed(new_amount: int)

## All countries must have a unique id
## for the purposes of saving/loading/syncing.
var id: int = -1

@export var country_name: String = ""
@export var color: Color = Color.WHITE

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
