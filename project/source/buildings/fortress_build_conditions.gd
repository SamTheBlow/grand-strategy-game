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
	_country.money_changed.connect(_on_money_changed)
	_province.buildings.changed.connect(_on_buildings_changed)
	
	_can_build = _all_conditions_are_met()


func can_build() -> bool:
	return _can_build


func _all_conditions_are_met() -> bool:
	if not _game.rules.build_fortress_enabled.value:
		error_message = "The game's rules don't allow it!"
		return false
	
	if _province.owner_country != _country:
		error_message = "The province is not under the country's control!"
		return false
	
	var fortress_price: int = _game.rules.fortress_price.value
	if _country.money < fortress_price:
		error_message = (
				"The country doesn't have enough money! "
				+ "It needs " + str(fortress_price)
				+ ", but only has " + str(_country.money) + "."
		)
		return false
	
	if _province.buildings.number_of_type(Building.Type.FORTRESS) > 0:
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


func _on_money_changed(money: int) -> void:
	_check_condition(money >= _game.rules.fortress_price.value)


func _on_buildings_changed() -> void:
	_check_condition(
			_province.buildings.number_of_type(Building.Type.FORTRESS) == 0
	)
