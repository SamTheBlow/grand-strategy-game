class_name ArmyRecruitmentLimit
## Class responsible for determining the maximum number
## of troops a given country can recruit in a given province.
##
## When the maximum number changes, the signal "changed" is emitted.
## The signals passes the new maximum as an argument.
##
## You can get the maximum manually with the "maximum" method.
##
## When the maximum number is 0, which means armies cannot be recruited,
## a human-friendly error message is stored in the "error_message" property.


signal changed(new_maximum: int)

var error_message: String = ""

var _country: Country
var _province: Province
var _maximum: int


func _init(country: Country, province: Province) -> void:
	_country = country
	_province = province
	
	_province.owner_changed.connect(_on_province_owner_changed)
	_country.money_changed.connect(_on_money_changed)
	_province.population.size_changed.connect(_on_population_size_changed)
	
	_maximum = _calculate_maximum()


func maximum() -> int:
	return _maximum


func _recalculate() -> void:
	var old_maximum: int = _maximum
	_maximum = _calculate_maximum()
	if _maximum != old_maximum:
		changed.emit(_maximum)


func _calculate_maximum() -> int:
	var game: Game = _province.game
	
	if not game.rules.recruitment_enabled:
		error_message = "The game's rules don't allow it!"
		return 0
	
	if _province.owner_country != _country:
		error_message = "The province is not under your country's control!"
		return 0
	
	# Money
	var money_per_unit: float = game.rules.recruitment_money_per_unit
	var money_for_one_troop: int = ceili(money_per_unit)
	if _country.money < money_for_one_troop:
		error_message = (
				"Your country doesn't have enough money to recruit any. "
				+ "One troop costs " + str(money_for_one_troop) + " money, "
				+ "but you only have " + str(_country.money) + "."
		)
		return 0
	var max_troops_with_money: int = floori(_country.money / money_per_unit)
	
	# Population
	var population_size: int = _province.population.population_size
	var pop_per_unit: float = game.rules.recruitment_population_per_unit
	var pop_for_one_troop: int = ceili(pop_per_unit)
	if population_size < pop_for_one_troop:
		error_message = (
				"The province doesn't have enough population for recruiting. "
				+ "One troop costs " + str(pop_for_one_troop) + " population, "
				+ "but the province only has " + str(population_size) + "."
		)
		return 0
	var max_troops_with_pop: int = floori(population_size / pop_per_unit)
	
	error_message = ""
	return mini(max_troops_with_money, max_troops_with_pop)


func _check_condition(condition: bool) -> void:
	if _maximum > 0:
		if condition:
			return
		# It will always be 0, but we also need to update the error message
		_maximum = _calculate_maximum()
	else:
		if not condition:
			return
		_maximum = _calculate_maximum()
		if _maximum == 0:
			return
	
	changed.emit(_maximum)


func _on_province_owner_changed(country: Country) -> void:
	_check_condition(country == _country)


func _on_money_changed(_money: int) -> void:
	_recalculate()


func _on_population_size_changed(_population_size: int) -> void:
	_recalculate()
