class_name FortressBuyConditions
## Class responsible for whether or not
## a player can buy a fortress in a given province.
##
## On the very moment that the player is (or isn't) now able to buy one,
## the signal "can_buy_changed" is emitted.
##
## If you need to check manually, you can use the "can_buy" method.
## If you can't buy one, the property "error_message" will contain
## a human-readable explanation as to why.


signal can_buy_changed(can_buy: bool)


var error_message: String = ""

var _country: Country
var _province: Province
var _can_buy: bool


func _init(country: Country, province: Province) -> void:
	_country = country
	_province = province
	
	_province.owner_country_changed.connect(_on_province_owner_changed)
	_country.money_changed.connect(_on_money_changed)
	_province.buildings.changed.connect(_on_buildings_changed)
	
	_can_buy = _all_conditions_are_met()


func _on_province_owner_changed(owner_country: Country) -> void:
	_check_condition(owner_country == _country)


func _on_money_changed(money: int) -> void:
	_check_condition(money >= _province.game.rules.fortress_price)


func _on_buildings_changed() -> void:
	var there_is_no_fortress: bool = true
	for building in _province.buildings._buildings:
		if building is Fortress:
			there_is_no_fortress = false
			break
	
	_check_condition(there_is_no_fortress)


func can_buy() -> bool:
	return _can_buy


func _all_conditions_are_met() -> bool:
	var game: Game = _province.game
	
	if not game.rules.can_buy_fortress:
		error_message = "The game's rules don't allow it!"
		return false
	
	if _province.owner_country() != _country:
		error_message = "The province is not under your country's control!"
		return false
	
	if _country.money < game.rules.fortress_price:
		error_message = (
				"Your country doesn't have enough money! "
				+ "It needs " + str(game.rules.fortress_price)
				+ ", but only has " + str(_country.money) + "."
		)
		return false
	
	for building in _province.buildings._buildings:
		if building is Fortress:
			error_message = "There is already a fortress in the province."
			return false
	
	error_message = ""
	return true


func _check_condition(condition: bool) -> void:
	if _can_buy:
		if condition:
			return
		# It will always be false, but we also need to update the error message
		_can_buy = _all_conditions_are_met()
	else:
		if not condition:
			return
		_can_buy = _all_conditions_are_met()
		if not _can_buy:
			return
	
	can_buy_changed.emit(_can_buy)
