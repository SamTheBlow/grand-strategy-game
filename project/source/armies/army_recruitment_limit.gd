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

var country: Country:
	set(value):
		if country == value:
			return

		# Disconnect signals
		if country != null:
			country.money_changed.disconnect(_on_money_changed)

		country = value

		# Connect signals
		country.money_changed.connect(_on_money_changed)

		_update()

var province: Province:
	set(value):
		if province == value:
			return

		# Disconnect signals
		if province != null:
			province.owner_changed.disconnect(_on_province_owner_changed)
			province.population().value_changed.connect(
					_on_population_size_changed
			)

		province = value

		# Connect signals
		province.owner_changed.connect(_on_province_owner_changed)
		province.population().value_changed.connect(
				_on_population_size_changed
		)

		_update()

var _game: Game
var _minimum: int
var _maximum: int


func _init(game: Game, country_: Country, province_: Province) -> void:
	_game = game
	country = country_
	province = province_


func minimum() -> int:
	return _minimum


func maximum() -> int:
	return _maximum


func _update() -> void:
	if country == null or province == null:
		return
	_update_minimum()
	_update_maximum()


func _update_minimum() -> void:
#	var old_minimum: int = _minimum
	_minimum = _calculated_minimum()
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
	var armies_in_province: Array[Army] = (
			_game.world.armies_in_each_province.in_province(province).list
	)
	for army in armies_in_province:
		if army.owner_country == country and army.is_able_to_move():
			return 0

	return _game.rules.minimum_army_size.value


func _calculated_maximum() -> int:
	if not _game.rules.recruitment_enabled.value:
		error_message = "The game's rules don't allow for recruitment!"
		return 0

	if province.owner_country != country:
		error_message = "The province is not under your country's control!"
		return 0

	# Puts in here all the different limits
	# and at the end takes the smallest one.
	var maximums: Array[int] = []

	# Money
	var money_per_unit: float = _game.rules.recruitment_money_per_unit.value
	var money_for_one_troop: int = ceili(money_per_unit)
	if country.money < money_for_one_troop:
		error_message = (
				"Your country doesn't have enough money to recruit any. "
				+ "One troop costs " + str(money_for_one_troop) + " money, "
				+ "but you only have " + str(country.money) + "."
		)
		return 0
	if money_per_unit != 0.0:
		var max_troops_with_money: int = floori(country.money / money_per_unit)
		maximums.append(max_troops_with_money)

	# Population
	var population_size: int = province.population().value
	var pop_per_unit: float = _game.rules.recruitment_population_per_unit.value
	var pop_for_one_troop: int = ceili(pop_per_unit)
	if population_size < pop_for_one_troop:
		error_message = (
				"The province doesn't have enough population for recruiting. "
				+ "One troop costs " + str(pop_for_one_troop) + " population, "
				+ "but the province only has " + str(population_size) + "."
		)
		return 0
	if pop_per_unit != 0.0:
		var max_troops_with_pop: int = floori(population_size / pop_per_unit)
		maximums.append(max_troops_with_pop)

	if maximums.size() == 0:
		error_message = "There is no limit on how many you can recruit!"
		return 0

	# Takes the smallest of the limits.
	var smallest_maximum: int = -1
	for candidate_max in maximums:
		if smallest_maximum == -1 or candidate_max < smallest_maximum:
			smallest_maximum = candidate_max

	error_message = ""
	return smallest_maximum


func _check_condition(condition: bool) -> void:
	if _maximum > 0:
		if condition:
			return
		# It will always be 0, but we need to update the error message
		_maximum = _calculated_maximum()
	else:
		if not condition:
			return
		_maximum = _calculated_maximum()
		if _maximum == 0:
			return

	maximum_changed.emit(_maximum)


func _on_province_owner_changed(_province: Province) -> void:
	_check_condition(province.owner_country == country)


func _on_money_changed(_money: int) -> void:
	_update_maximum()


func _on_population_size_changed(_population_size: int) -> void:
	_update_maximum()
