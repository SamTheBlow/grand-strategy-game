class_name Province
## In a game, a province represents a certain area on the world map.
## It may be of any size or shape, and
## it may or may not be under the control of a [Country].
##
## This class has many responsibilities, as many game mechanics involve
## their presence on a province: [Population], [Building], [IncomeMoney].
##
## See [method GameFromRawDict._load_province]
## to see how to initialize a new province.

signal owner_changed(this: Province)

## The unique id assigned to this province.
## Each province has its own id. Useful for saving/loading, networking, etc.
var id: int = -1

## A list of all the provinces that are
## neighboring this province, e.g. when moving armies.
var links: Array[Province] = []

## The [Country] in control of this province. This can be null.
## Must initialize when the province is created.
var owner_country: Country:
	set(value):
		if value == owner_country:
			return
		owner_country = value
		owner_changed.emit(self)

var population: Population

var buildings := Buildings.new()

## The list of vertices forming this province's polygon shape.
var polygon: PackedVector2Array

## The position to give to the visuals.
var position: Vector2

## Where this province's [ArmyStack2D] will be positioned,
## relative to this province's position.
var position_army_host: Vector2:
	set(value):
		position_army_host = value
		position_fortress = position_army_host + Vector2(80.0, 56.0)

## Where this province's [Fortress] will be positioned,
## relative to this province's position.
## (This property is automatically determined when setting _position_army_host.)
var position_fortress: Vector2

## How much money (the in-game resource)
## this province generates per [GameTurn].
var _income_money: IncomeMoney

## Add to this array any object that you want to keep in scope
## for as long as this province is in scope.
var _components: Array = []


func add_component(object: Object) -> void:
	_components.append(object)


func income_money() -> IncomeMoney:
	return _income_money


func is_linked_to(province: Province) -> bool:
	return links.has(province)


## Returns true if all the following conditions are met:
## - Given [Country] has military access to this province.
## - This province is not unclaimed.
## - At least one of this province's links is either unclaimed or
##   under control of a country which given country cannot move into.
func is_frontline(country: Country) -> bool:
	if not country.has_permission_to_move_into_country(owner_country):
		return false

	if owner_country == null:
		return false

	for link in links:
		if (
				link.owner_country == null
				or not country
				.has_permission_to_move_into_country(link.owner_country)
		):
			return true

	return false


## Returns true if all the following conditions are met:
## - Given [Country] has military access to this province.
## - This province is not unclaimed.
## - At least one of this province's links is either unclaimed or
##   under control of a country which given country is currently fighting.
func is_war_frontline(country: Country) -> bool:
	if not country.has_permission_to_move_into_country(owner_country):
		return false

	if owner_country == null:
		return false

	for link in links:
		if (
				link.owner_country == null
				or
				country.relationships
				.with_country(link.owner_country).is_fighting()
		):
			return true

	return false


## Returns the nearest province(s).
## It may return more than one province if there's a tie.
## It may also return an empty array if there is no valid province.
## Optionally, you can provide a filter callable.
## The filter must take one input of type Province and must return a boolean.
## The filter lets you get the nearest province that fulfills
## specific conditions. (e.g. "the nearest province that you own")
func nearest_provinces(
		province_filter: Callable = (
				func(_province: Province) -> bool: return true
		)
) -> Array[Province]:
	var calculation := NearestProvinces.new()
	calculation.calculate(self, province_filter)
	return calculation.furthest_links
