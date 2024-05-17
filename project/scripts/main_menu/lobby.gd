class_name Lobby
extends Control


signal start_game_requested(scenario: PackedScene, rules: GameRules)

@export var scenario_scene: PackedScene

@export var player_list: PlayerList


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	_update_rules_disabled()
	_update_start_button_disabled()


func _selected_game_rules() -> GameRules:
	var game_rules := GameRules.new()
	
	game_rules.turn_limit_enabled = (
			(%TurnLimitEnabled as CheckBox).button_pressed
	)
	game_rules.turn_limit = roundi((%TurnLimit as SpinBox).value)
	
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
	game_rules.build_fortress_enabled = (
			(%BuildFortressEnabled as CheckBox).button_pressed
	)
	game_rules.fortress_price = roundi((%FortressPrice as SpinBox).value)
	
	game_rules.starting_money = roundi((%StartingMoney as SpinBox).value)
	
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
	
	game_rules.minimum_army_size = roundi((%MinimumArmySize as SpinBox).value)
	
	game_rules.global_attacker_efficiency = (
			(%AttackerEfficiency as SpinBox).value
	)
	game_rules.global_defender_efficiency = (
			(%DefenderEfficiency as SpinBox).value
	)
	game_rules.battle_algorithm = (
			(%BattleAlgorithm as OptionButton).selected
	)
	
	return game_rules


# TODO this is cursed... *skull emoji*
func _get_rule(rule_name: String) -> Variant:
	var output: Variant
	
	match rule_name:
		"turn_limit_enabled":
			output = (%TurnLimitEnabled as CheckBox).button_pressed
		"turn_limit":
			output = roundi((%TurnLimit as SpinBox).value)
		"reinforcements_enabled":
			output = (%Reinforcements as CheckBox).button_pressed
		"reinforcements_option":
			output = (%ReinforcementOptions as OptionButton).selected
		"reinforcements_random_min":
			output = roundi((%ReinforcementsRandomMin as SpinBox).value)
		"reinforcements_random_max":
			output = roundi((%ReinforcementsRandomMax as SpinBox).value)
		"reinforcements_constant":
			output = roundi((%ReinforcementsConstant as SpinBox).value)
		"reinforcements_per_person":
			output = (%ReinforcementsPerPerson as SpinBox).value
		"recruitment_enabled":
			output = (%CanRecruit as CheckBox).button_pressed
		"recruitment_money_per_unit":
			output = (%RecruitMoneyPerUnit as SpinBox).value
		"recruitment_population_per_unit":
			output = (%RecruitPopulationPerUnit as SpinBox).value
		"population_growth_enabled":
			output = (%PopulationGrowth as CheckBox).button_pressed
		"population_growth_rate":
			output = (%PopulationGrowthRate as SpinBox).value
		"extra_starting_population":
			output = roundi((%ExtraStartingPopulation as SpinBox).value)
		"start_with_fortress":
			output = (%StartWithFortress as CheckBox).button_pressed
		"build_fortress_enabled":
			output = (%BuildFortressEnabled as CheckBox).button_pressed
		"fortress_price":
			output = roundi((%FortressPrice as SpinBox).value)
		"starting_money":
			output = roundi((%StartingMoney as SpinBox).value)
		"province_income_option":
			output = (%ProvinceIncomeOptions as OptionButton).selected
		"province_income_random_min":
			output = roundi((%ProvinceIncomeRandomMin as SpinBox).value)
		"province_income_random_max":
			output = roundi((%ProvinceIncomeRandomMax as SpinBox).value)
		"province_income_constant":
			output = roundi((%ProvinceIncomeConstant as SpinBox).value)
		"province_income_per_person":
			output = (%ProvinceIncomePerPerson as SpinBox).value
		"minimum_army_size":
			output = roundi((%MinimumArmySize as SpinBox).value)
		"global_attacker_efficiency":
			output = (%AttackerEfficiency as SpinBox).value
		"global_defender_efficiency":
			output = (%DefenderEfficiency as SpinBox).value
		"battle_algorithm":
			output = (%BattleAlgorithm as OptionButton).selected
	
	return output


func _set_rule(rule_name: String, value: Variant) -> void:
	match rule_name:
		"turn_limit_enabled":
			(%TurnLimitEnabled as CheckBox).button_pressed = value
		"turn_limit":
			(%TurnLimit as SpinBox).value = value
		"reinforcements_enabled":
			(%Reinforcements as CheckBox).button_pressed = value
		"reinforcements_option":
			(%ReinforcementOptions as CustomOptionButton).select_item(value)
		"reinforcements_random_min":
			(%ReinforcementsRandomMin as SpinBox).value = value
		"reinforcements_random_max":
			(%ReinforcementsRandomMax as SpinBox).value = value
		"reinforcements_constant":
			(%ReinforcementsConstant as SpinBox).value = value
		"reinforcements_per_person":
			(%ReinforcementsPerPerson as SpinBox).value = value
		"recruitment_enabled":
			(%CanRecruit as CheckBox).button_pressed = value
		"recruitment_money_per_unit":
			(%RecruitMoneyPerUnit as SpinBox).value = value
		"recruitment_population_per_unit":
			(%RecruitPopulationPerUnit as SpinBox).value = value
		"population_growth_enabled":
			(%PopulationGrowth as CheckBox).button_pressed = value
		"population_growth_rate":
			(%PopulationGrowthRate as SpinBox).value = value
		"extra_starting_population":
			(%ExtraStartingPopulation as SpinBox).value = value
		"start_with_fortress":
			(%StartWithFortress as CheckBox).button_pressed = value
		"build_fortress_enabled":
			(%BuildFortressEnabled as CheckBox).button_pressed = value
		"fortress_price":
			(%FortressPrice as SpinBox).value = value
		"starting_money":
			(%StartingMoney as SpinBox).value = value
		"province_income_option":
			(%ProvinceIncomeOptions as CustomOptionButton).select_item(value)
		"province_income_random_min":
			(%ProvinceIncomeRandomMin as SpinBox).value = value
		"province_income_random_max":
			(%ProvinceIncomeRandomMax as SpinBox).value = value
		"province_income_constant":
			(%ProvinceIncomeConstant as SpinBox).value = value
		"province_income_per_person":
			(%ProvinceIncomePerPerson as SpinBox).value = value
		"minimum_army_size":
			(%MinimumArmySize as SpinBox).value = value
		"global_attacker_efficiency":
			(%AttackerEfficiency as SpinBox).value = value
		"global_defender_efficiency":
			(%DefenderEfficiency as SpinBox).value = value
		"battle_algorithm":
			(%BattleAlgorithm as CustomOptionButton).select_item(value)


# TODO DRY: copy/pasted from players.gd
## Returns true if (and only if) you are connected.
func _is_connected() -> bool:
	return (
			multiplayer
			and multiplayer.has_multiplayer_peer()
			and multiplayer.multiplayer_peer.get_connection_status()
			== MultiplayerPeer.CONNECTION_CONNECTED
	)


#region Synchronize all the rules
## Clients call this to ask the server for a full synchronization.
## Has no effect if you're the server.
func _request_all_data() -> void:
	if multiplayer.is_server():
		return
	
	_send_all_data.rpc_id(1)


@rpc("any_peer", "call_remote", "reliable")
func _send_all_data() -> void:
	if not multiplayer.is_server():
		print_debug("Received server request, but you're not the server.")
		return
	
	var data := {}
	for rule_name in GameRules.RULE_NAMES:
		data[rule_name] = _get_rule(rule_name)
	_receive_all_data.rpc(data)


@rpc("authority", "call_remote", "reliable")
func _receive_all_data(data: Dictionary) -> void:
	for rule_name: String in data.keys():
		_set_rule(rule_name, data.get(rule_name))
#endregion


#region Synchronize one specific rule
## The server calls this to inform clients of a rule change.
## This function has no effect if you're not connected as a server.
func _send_rule_change_to_clients(rule_name: String) -> void:
	if not (_is_connected() and multiplayer.is_server()):
		return
	
	_receive_rule_change.rpc(rule_name, _get_rule(rule_name))


@rpc("authority", "call_remote", "reliable")
func _receive_rule_change(rule_name: String, value: Variant) -> void:
	_set_rule(rule_name, value)
#endregion


## When connected to an online game, only the server is allowed to
## make changes to the rules.
func _update_rules_disabled() -> void:
	var rules_disabled_node := %RulesDisabled as Control
	
	if _is_connected():
		rules_disabled_node.visible = not multiplayer.is_server()
	else:
		rules_disabled_node.visible = false


## When connected to an online game,
## only the server is allowed to start the game.
func _update_start_button_disabled() -> void:
	var start_button := %StartButton as Button
	
	if _is_connected():
		start_button.disabled = not multiplayer.is_server()
	else:
		start_button.disabled = false


func _on_start_button_pressed() -> void:
	start_game_requested.emit(scenario_scene, _selected_game_rules())


func _on_connected_to_server() -> void:
	_request_all_data()
	_update_rules_disabled()
	_update_start_button_disabled()


func _on_server_disconnected() -> void:
	_update_rules_disabled()
	_update_start_button_disabled()


#region Signal functions for all the rules
func _on_turn_limit_enabled_pressed() -> void:
	_send_rule_change_to_clients("turn_limit_enabled")


func _on_turn_limit_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("turn_limit")


func _on_reinforcements_pressed() -> void:
	_send_rule_change_to_clients("reinforcements_enabled")


func _on_reinforcement_options_item_selected(_index: int) -> void:
	_send_rule_change_to_clients("reinforcements_option")


func _on_reinforcements_random_min_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("reinforcements_random_min")


func _on_reinforcements_random_max_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("reinforcements_random_max")


func _on_reinforcements_constant_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("reinforcements_constant")


func _on_reinforcements_per_person_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("reinforcements_per_person")


func _on_can_recruit_pressed() -> void:
	_send_rule_change_to_clients("recruitment_enabled")


func _on_recruit_money_per_unit_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("recruitment_money_per_unit")


func _on_recruit_population_per_unit_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("recruitment_population_per_unit")


func _on_population_growth_pressed() -> void:
	_send_rule_change_to_clients("population_growth_enabled")


func _on_population_growth_rate_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("population_growth_rate")


func _on_extra_starting_population_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("extra_starting_population")


func _on_start_with_fortress_pressed() -> void:
	_send_rule_change_to_clients("start_with_fortress")


func _on_build_fortress_enabled_pressed() -> void:
	_send_rule_change_to_clients("build_fortress_enabled")


func _on_fortress_price_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("fortress_price")


func _on_starting_money_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("starting_money")


func _on_province_income_options_item_selected(_index: int) -> void:
	_send_rule_change_to_clients("province_income_option")


func _on_province_income_random_min_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("province_income_random_min")


func _on_province_income_random_max_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("province_income_random_max")


func _on_province_income_constant_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("province_income_constant")


func _on_province_income_per_person_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("province_income_per_person")


func _on_minimum_army_size_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("minimum_army_size")


func _on_attacker_efficiency_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("global_attacker_efficiency")


func _on_defender_efficiency_value_changed(_value: float) -> void:
	_send_rule_change_to_clients("global_defender_efficiency")


func _on_battle_algorithm_item_selected(_index: int) -> void:
	_send_rule_change_to_clients("battle_algorithm")
#endregion
