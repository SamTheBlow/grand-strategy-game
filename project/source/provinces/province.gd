class_name Province
## In a game, a province represents a certain area on the world map.
## It may be of any size or shape, and
## it may or may not be under the control of a [Country].
##
## This class has many responsibilities, as many game mechanics involve
## their presence on a province: [Population], [Building], [IncomeMoney].

signal link_added(linked_province_id: int)
signal link_removed(linked_province_id: int)
signal links_reset()
signal owner_changed(this: Province)
signal position_changed(this: Province)

## Unique identifier. Useful for saving/loading, networking, etc.
var id: int = -1

## This province's name.
var name: String = ""

## The [Country] in control of this province. This can be null.
## Must initialize when the province is created.
var owner_country: Country:
	set(value):
		if value == owner_country:
			return
		owner_country = value
		owner_changed.emit(self)

var population: Population

## How much money (the in-game resource)
## this province generates per [GameTurn].
var income_money: IncomeMoney

var buildings := Buildings.new()

## The list of vertices forming this province's polygon shape.
var polygon: PackedVector2Array

## The position to give to the visuals.
var position: Vector2:
	set(value):
		if value == position:
			return
		position = value
		position_changed.emit(self)

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

## A list of IDs for all the provinces that are
## neighboring this province, e.g. when moving armies.
var _linked_province_ids: Array[int] = []


## The default name this province would have if it didn't have a name.
func default_name() -> String:
	return "Province " + str(id)


## This province's name, or its default name if the name is empty.
func name_or_default() -> String:
	if name != "":
		return name
	else:
		return default_name()


## Returns a list of all the provinces linked to this province.
## Feel free to edit the list.
func linked_province_ids() -> Array[int]:
	return _linked_province_ids


func is_linked_to(province_id: int) -> bool:
	return _linked_province_ids.has(province_id)


## No effect if given province is already linked.
## No effect if given province id is the same as this province's.
func add_link(province_id: int) -> void:
	if province_id == id or _linked_province_ids.has(province_id):
		return
	_linked_province_ids.append(province_id)
	link_added.emit(province_id)


## No effect if given province is already not linked.
func remove_link(province_id: int) -> void:
	if _linked_province_ids.has(province_id):
		_linked_province_ids.erase(province_id)
		link_removed.emit(province_id)


## Adds given province to the links if it's not a link, otherwise removes it.
func toggle_link(province_id: int) -> void:
	if _linked_province_ids.has(province_id):
		remove_link(province_id)
	else:
		add_link(province_id)


func reset_links() -> void:
	_linked_province_ids = []
	links_reset.emit()


## Returns true if all the following conditions are met:
## - Given [Country] has military access to this province.
## - This province is not unclaimed.
## - At least one of this province's links is either unclaimed or
##   under control of a country which given country cannot move into.
func is_frontline(country: Country, provinces: Provinces) -> bool:
	if not country.has_permission_to_move_into_country(owner_country):
		return false

	if owner_country == null:
		return false

	for linked_province in provinces.links_of(id):
		if (
				linked_province.owner_country == null
				or not country.has_permission_to_move_into_country(
						linked_province.owner_country
				)
		):
			return true

	return false


## Returns true if all the following conditions are met:
## - Given [Country] has military access to this province.
## - This province is not unclaimed.
## - At least one of this province's links is either unclaimed or
##   under control of a country which given country is currently fighting.
func is_war_frontline(country: Country, provinces: Provinces) -> bool:
	if not country.has_permission_to_move_into_country(owner_country):
		return false

	if owner_country == null:
		return false

	for linked_province in provinces.links_of(id):
		if (
				linked_province.owner_country == null
				or
				country.relationships
				.with_country(linked_province.owner_country).is_fighting()
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
		provinces: Provinces,
		province_filter: Callable = (
				func(_province: Province) -> bool: return true
		)
) -> Array[Province]:
	var calculation := NearestProvinces.new()
	calculation.calculate(id, provinces, province_filter)
	return calculation.furthest_links
