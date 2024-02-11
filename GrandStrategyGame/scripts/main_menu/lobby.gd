class_name Lobby
extends Control


signal start_game_requested(scenario: PackedScene, rules: GameRules)


@export var scenario_scene: PackedScene


func _on_start_button_pressed() -> void:
	start_game_requested.emit(scenario_scene, _selected_game_rules())


func _selected_game_rules() -> GameRules:
	var game_rules := GameRules.new()
	
	game_rules.population_growth = (
			(%PopulationGrowth as CheckBox).button_pressed
	)
	game_rules.extra_starting_population = (
			roundi((%ExtraStartingPopulation as SpinBox).value)
	)
	
	game_rules.start_with_fortress = (
			(%StartWithFortress as CheckBox).button_pressed
	)
	game_rules.can_buy_fortress = (
			(%CanBuyFortress as CheckBox).button_pressed
	)
	game_rules.fortress_price = (
			roundi((%FortressPrice as SpinBox).value)
	)
	
	var turn_limit_check_box := %TurnLimitCheckBox as CheckBox
	game_rules.turn_limit_enabled = turn_limit_check_box.button_pressed
	game_rules.turn_limit = roundi((%TurnLimitSpinBox as SpinBox).value)
	
	var starting_money_spin_box := %StartingMoneySpinBox as SpinBox
	game_rules.starting_money = roundi(starting_money_spin_box.value)
	
	game_rules.province_income_option = (
			(%ProvinceIncomeOptions as OptionButton).selected
	)
	game_rules.province_income_random_min = (
			roundi((%ProvinceIncomeRandomMin as SpinBox).value)
	)
	game_rules.province_income_random_max = (
			roundi((%ProvinceIncomeRandomMax as SpinBox).value)
	)
	game_rules.province_income_constant = (
			roundi((%ProvinceIncomeConstant as SpinBox).value)
	)
	game_rules.province_income_per_person = (
			(%ProvinceIncomePerPerson as SpinBox).value
	)
	
	var att_eff := %AttackerEfficiencySpinBox as SpinBox
	game_rules.global_attacker_efficiency = att_eff.value
	
	var def_eff := %DefenderEfficiencySpinBox as SpinBox
	game_rules.global_defender_efficiency = def_eff.value
	
	return game_rules
