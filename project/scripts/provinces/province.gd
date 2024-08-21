class_name Province
extends Node2D
## In a game, a province represents a certain area on the world map.
## It may be of any size or shape, and
## it may or may not be under the control of a [Country].
##
## This class has many responsibilities, as many game mechanics
## involve their presence on a province:
## [Army], [Population], [Building], [IncomeMoney].
##
## See [method GameFromRawDict._load_province]
## to see how to initialize a new province.
# TODO move visuals to their own class


## See [signal ProvinceShapePolygon2D.unhandled_mouse_event_occured]
signal unhandled_mouse_event_occured(event: InputEventMouse, this: Province)
## See [signal ProvinceShapePolygon2D.mouse_event_occured]
signal mouse_event_occured(event: InputEventMouse, this: Province)

signal selected()
signal deselected()

signal owner_changed(this: Province)

## External reference
var game: Game:
	set(value):
		if game:
			unhandled_mouse_event_occured.disconnect(
					game._on_province_unhandled_mouse_event
			)
			selected.disconnect(game._on_province_selected)
			deselected.disconnect(game._on_province_deselected)
			game.turn.turn_changed.disconnect(_on_new_turn)
		
		game = value
		
		unhandled_mouse_event_occured.connect(
				game._on_province_unhandled_mouse_event
		)
		selected.connect(game._on_province_selected)
		deselected.connect(game._on_province_deselected)
		game.turn.turn_changed.connect(_on_new_turn)

## All provinces must have a unique id for the purposes of saving/loading.
## The node's name always matches its id.
var id: int:
	set(value):
		id = value
		name = str(id)

# Nodes
var army_stack: ArmyStack
var buildings: Buildings

## Where this province's [ArmyStack] will be positioned,
## relative to this province's position.
var position_army_host: Vector2

## A list of all the provinces that are
## neighboring this province, e.g. when moving armies.
var links: Array[Province] = []

## The [Country] in control of this province. This can be null.
## Must initialize when the province is created.
var owner_country: Country:
	get:
		# This is to preserve compatibility with 4.0 version.
		# In 4.0, owner_country was never null, and
		# an unclaimed country was a country with a negative id.
		if owner_country and owner_country.id < 0:
			return null
		return owner_country
	set(value):
		if value == owner_country:
			return
		owner_country = value
		owner_changed.emit(self)

## How much money (the in-game resource)
## this province generates per [GameTurn].
var _income_money: IncomeMoney

var population: Population

## The list of vertices forming this province's polygon shape.
var polygon: PackedVector2Array:
	get:
		return _shape.polygon
	set(value):
		_shape.polygon = value

var _shape: ProvinceShapePolygon2D:
	get:
		if not _shape:
			_shape = $Shape as ProvinceShapePolygon2D
		return _shape


## To be called when this node is created.
func init() -> void:
	_setup_army_stack()
	_setup_buildings()


func income_money() -> IncomeMoney:
	return _income_money


func select() -> void:
	_highlight_links()
	selected.emit()


func deselect() -> void:
	deselected.emit()


func highlight_shape(is_target: bool) -> void:
	_shape.highlight(is_target)


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


func mouse_is_inside_shape() -> bool:
	return _shape.mouse_is_inside_shape()


## Debug function that clearly highlights this province on the world map.
## To remove the highlight, pass false as an argument.
func highlight_debug(
		outline_color: Color = Color.BLUE, show_highlight: bool = true
) -> void:
	if has_node("DebugHighlight"):
		remove_child(get_node("DebugHighlight"))
	
	if not show_highlight:
		return
	
	var debug_highlight := ProvinceShapePolygon2D.new()
	debug_highlight.name = "DebugHighlight"
	debug_highlight.color = Color(0.0, 0.0, 0.0, 0.0)
	debug_highlight.polygon = _shape.polygon
	debug_highlight.outline_color = outline_color
	debug_highlight._outline_type = (
			ProvinceShapePolygon2D.OutlineType.HIGHLIGHT_TARGET
	)
	add_child(debug_highlight)


func _setup_army_stack() -> void:
	army_stack = ArmyStack.new()
	army_stack.name = "ArmyStack"
	army_stack.position = position_army_host
	add_child(army_stack)


func _setup_buildings() -> void:
	buildings = Buildings.new()
	buildings.name = "Buildings"
	add_child(buildings)


func _highlight_links() -> void:
	var has_valid_army: bool = false
	var active_armies: Array[Army] = (
			game.world.armies
			.active_armies(game.turn.playing_player().playing_country, self)
	)
	var army: Army
	if active_armies.size() > 0:
		army = active_armies[0]
		has_valid_army = true
	
	for link in links:
		link.highlight_shape(has_valid_army and army.can_move_to(link))


func _on_new_turn(_turn: int) -> void:
	ArmyReinforcements.new().reinforce_province(self)
	if owner_country:
		owner_country.money += _income_money.total()


func _on_shape_unhandled_mouse_event_occured(event: InputEventMouse) -> void:
	unhandled_mouse_event_occured.emit(event, self)


func _on_shape_mouse_event_occured(event: InputEventMouse) -> void:
	mouse_event_occured.emit(event, self)
