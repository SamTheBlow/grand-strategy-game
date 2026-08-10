class_name FortressBuildConditions
## Determines whether or not a given country
## can build a fortress in a given province.
##
## Emits a signal right when the country becomes able/unable to build one.
##
## If you need to check manually, you can use the "can_build" method.
## If you can't build one, the property "error_message" will contain
## a human-readable explanation as to why.

signal can_build_changed(can_build: bool)

var error_message: String = ""

var _country: Country
var _province: Province
var _game: Game
var _can_build: bool


func _init(country: Country, province: Province, game: Game) -> void:
	_country = country
	_province = province
	_game = game

	_province.owner_changed.connect(_on_province_owner_changed)
	_province.population().value_changed.connect(_on_population_changed)
	_country.money_changed.connect(_on_money_changed)
	_province.buildings.changed.connect(_on_buildings_changed)

	_can_build = _all_conditions_are_met()


func can_build() -> bool:
	return _can_build


func _all_conditions_are_met() -> bool:
	var fortress_data: BuildingData = _game.world.fortress_data()

	if not fortress_data.can_be_built:
		error_message = "This building can't be built by players!"
		return false

	if _province.owner_country != _country:
		error_message = "The province is not under the country's control!"
		return false

	if _province.population().value < fortress_data.population_cost:
		error_message = (
				"The province doesn't have enough population! "
				+ "It needs " + str(fortress_data.population_cost)
				+ ", but only has " + str(_province.population().value) + "."
		)
		return false

	if _country.money < fortress_data.money_cost:
		error_message = (
				"The country doesn't have enough money! "
				+ "It needs " + str(fortress_data.money_cost)
				+ ", but only has " + str(_country.money) + "."
		)
		return false

	if not _province.buildings.list().is_empty():
		error_message = "There is already a fortress in the province."
		return false

	error_message = ""
	return true


func _check_condition(condition: bool) -> void:
	if _can_build:
		if condition:
			return
		# It will always be false, but we also need to update the error message
		_can_build = _all_conditions_are_met()
	else:
		if not condition:
			return
		_can_build = _all_conditions_are_met()
		if not _can_build:
			return

	can_build_changed.emit(_can_build)


func _on_province_owner_changed(province: Province) -> void:
	_check_condition(province.owner_country == _country)


func _on_population_changed(value: int) -> void:
	_check_condition(value >= _game.world.fortress_data().population_cost)


func _on_money_changed(value: int) -> void:
	_check_condition(value >= _game.world.fortress_data().money_cost)


func _on_buildings_changed() -> void:
	_check_condition(_province.buildings.list().is_empty())
