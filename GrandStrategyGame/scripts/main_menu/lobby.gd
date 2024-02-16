class_name Lobby
extends Control


signal start_game_requested(scenario: PackedScene, rules: GameRules)


@export var scenario_scene: PackedScene


func _on_start_button_pressed() -> void:
	start_game_requested.emit(scenario_scene, _selected_game_rules())


func _selected_game_rules() -> GameRules:
	var game_rules := GameRules.new()
	
	var turn_limit_check_box := %TurnLimitCheckBox as CheckBox
	game_rules.turn_limit_enabled = turn_limit_check_box.button_pressed
	game_rules.turn_limit = roundi((%TurnLimitSpinBox as SpinBox).value)
	
	game_rules.reinforcements_enabled = (
			(%Reinforcements as CheckBox).button_pressed
	)
	game_rules.reinforcements_option = (
			(%ReinforcementOptions as OptionButton).selected
	)
	game_rules.reinforcements_random_min = (
			roundi((%ReinforcementsRandomMin as SpinBox).value)
	)
	game_rules.reinforcements_random_max = (
			roundi((%ReinforcementsRandomMax as SpinBox).value)
	)
	game_rules.reinforcements_constant = (
			roundi((%ReinforcementsConstant as SpinBox).value)
	)
	game_rules.reinforcements_per_person = (
			(%ReinforcementsPerPerson as SpinBox).value
	)
	
	game_rules.recruitment_enabled = (
			(%CanRecruit as CheckBox).button_pressed
	)
	game_rules.recruitment_money_per_unit = (
			(%RecruitMoneyPerUnit as SpinBox).value
	)
	game_rules.recruitment_population_per_unit = (
			(%RecruitPopulationPerUnit as SpinBox).value
	)
	
	game_rules.population_growth_enabled = (
			(%PopulationGrowth as CheckBox).button_pressed
	)
	game_rules.population_growth_rate = (
			(%PopulationGrowthRate as SpinBox).value
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
	
	game_rules.minimum_army_size = (
			roundi((%MinimumArmySize as SpinBox).value)
	)
	
	game_rules.global_attacker_efficiency = (
			(%AttackerEfficiencySpinBox as SpinBox).value
	)
	game_rules.global_defender_efficiency = (
			(%DefenderEfficiencySpinBox as SpinBox).value
	)
	
	return game_rules
