class_name ArmyRecruitmentLimits
## Class responsible for determining the minimum and maximum number
## of troops a given [Country] can recruit in a given [Province].
##
## Emits a signal when the maximum number changes.
## (There is currently no signal for the minimum number, though.)
## Also has functions to get the minimum and maximum manually.
##
## When the maximum number is 0, which means armies cannot be recruited,
## a human-friendly error message is stored in the "error_message" property.


#signal minimum_changed(new_minimum: int)
signal maximum_changed(new_maximum: int)

var error_message: String = ""

var _country: Country
var _province: Province
var _minimum: int
var _maximum: int


func _init(country: Country, province: Province) -> void:
	_country = country
	_province = province
	
	_province.owner_changed.connect(_on_province_owner_changed)
	_country.money_changed.connect(_on_money_changed)
	_province.population.size_changed.connect(_on_population_size_changed)
	
	_minimum = _calculated_minimum()
	_maximum = _calculated_maximum()


func minimum() -> int:
	return _minimum


func maximum() -> int:
	return _maximum


#func _update_minimum() -> void:
#	var old_minimum: int = _minimum
#	_minimum = _calculated_minimum()
#	if _minimum != old_minimum:
#		minimum_changed.emit(_minimum)


func _update_maximum() -> void:
	var old_maximum: int = _maximum
	_maximum = _calculated_maximum()
	if _maximum != old_maximum:
		maximum_changed.emit(_maximum)


func _calculated_minimum() -> int:
	# Because an army's size will always be at least the minimum size,
	# if the country controls any (active) army on the province,
	# then the minimum you can recruit will always be 0.
	for army in _province.game.world.armies.armies_in_province(_province):
		if army.owner_country == _country and army.is_able_to_move():
			return 0
	return _province.game.rules.minimum_army_size.value


func _calculated_maximum() -> int:
	var game: Game = _province.game
	
	if not game.rules.recruitment_enabled.value:
		error_message = "The game's rules don't allow for recruitment!"
		return 0
	
	if _province.owner_country != _country:
		error_message = "The province is not under your country's control!"
		return 0
	
	# Money
	var money_per_unit: float = game.rules.recruitment_money_per_unit.value
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
	var pop_per_unit: float = game.rules.recruitment_population_per_unit.value
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
		_maximum = _calculated_maximum()
	else:
		if not condition:
			return
		_maximum = _calculated_maximum()
		if _maximum == 0:
			return
	
	maximum_changed.emit(_maximum)


func _on_province_owner_changed(province: Province) -> void:
	_check_condition(province.owner_country == _country)


func _on_money_changed(_money: int) -> void:
	_update_maximum()


func _on_population_size_changed(_population_size: int) -> void:
	_update_maximum()
