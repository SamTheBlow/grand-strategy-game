class_name GameRules
extends Node
## Defines all the details on how a [Game] is to be played.
## This is just a data structure; it cannot enforce rules on its own.
## The different objects in the game must carefully read this object's
## properties in order to behave correctly.
##
## This class is also responsible for defining the rule layout,
## and for synchronizing the rules in online multiplayer.


## All of the individual rules.
## They must all point to a property in this class of type [RuleItem],
## and all of these [RuleItem]s must have a "value" property
## as well as a "value_changed" signal.
const RULE_NAMES: Array[String] = [
	"turn_limit_enabled",
	"turn_limit",
	"game_over_provinces_owned_option",
	"game_over_provinces_owned_constant",
	"game_over_provinces_owned_percentage",
	"reinforcements_enabled",
	"reinforcements_option",
	"reinforcements_random_min",
	"reinforcements_random_max",
	"reinforcements_constant",
	"reinforcements_per_person",
	"recruitment_enabled",
	"recruitment_money_per_unit",
	"recruitment_population_per_unit",
	"population_growth_enabled",
	"population_growth_rate",
	"extra_starting_population",
	"start_with_fortress",
	"build_fortress_enabled",
	"fortress_price",
	"starting_money",
	"province_income_option",
	"province_income_random_min",
	"province_income_random_max",
	"province_income_constant",
	"province_income_per_person",
	"minimum_army_size",
	"global_attacker_efficiency",
	"global_defender_efficiency",
	"battle_algorithm_option",
	"default_ai_type",
	"start_with_random_ai_type",
	"default_ai_personality_option",
	"start_with_random_ai_personality",
	"diplomacy_presets_option",
	"starts_with_random_relationship_preset",
	"grants_military_access_default",
	"can_grant_military_access",
	"can_revoke_military_access",
	"can_ask_for_military_access",
	"is_military_access_mutual",
	"is_military_access_revoked_when_fighting",
	"military_access_loss_behavior_option",
	"is_trespassing_default",
	"can_enable_trespassing",
	"can_disable_trespassing",
	"can_ask_to_stop_trespassing",
	"automatically_fight_trespassers",
	"is_fighting_default",
	"can_enable_fighting",
	"can_disable_fighting",
	"can_ask_to_stop_fighting",
	"automatically_fight_back",
]

enum ReinforcementsOption {
	RANDOM = 0,
	CONSTANT = 1,
	POPULATION = 2,
}

enum ProvinceIncome {
	RANDOM = 0,
	CONSTANT = 1,
	POPULATION = 2,
}

var diplomatic_actions: DiplomacyActionDefinitions

# Individual rules
var turn_limit_enabled: RuleBool
var turn_limit: RuleInt
var game_over_provinces_owned_option: RuleOptions
var game_over_provinces_owned_constant: RuleInt
var game_over_provinces_owned_percentage: RuleFloat
var reinforcements_enabled: RuleBool
var reinforcements_option: RuleOptions
var reinforcements_random_min: RuleInt
var reinforcements_random_max: RuleInt
var reinforcements_constant: RuleInt
var reinforcements_per_person: RuleFloat
var recruitment_enabled: RuleBool
var recruitment_money_per_unit: RuleFloat
var recruitment_population_per_unit: RuleFloat
var population_growth_enabled: RuleBool
var population_growth_rate: RuleFloat
var extra_starting_population: RuleInt
var start_with_fortress: RuleBool
var build_fortress_enabled: RuleBool
var fortress_price: RuleInt
var starting_money: RuleInt
var province_income_option: RuleOptions
var province_income_random_min: RuleInt
var province_income_random_max: RuleInt
var province_income_constant: RuleInt
var province_income_per_person: RuleFloat
var minimum_army_size: RuleInt
var global_attacker_efficiency: RuleFloat
var global_defender_efficiency: RuleFloat
var battle_algorithm_option: RuleOptions
var default_ai_type: RuleInt
var start_with_random_ai_type: RuleBool
var default_ai_personality_option: RuleOptions
var start_with_random_ai_personality: RuleBool
var diplomacy_presets_option: RuleOptions
var starts_with_random_relationship_preset: RuleBool
var grants_military_access_default: RuleBool
var can_grant_military_access: RuleBool
var can_revoke_military_access: RuleBool
var can_ask_for_military_access: RuleBool
var is_military_access_mutual: RuleBool
var is_military_access_revoked_when_fighting: RuleBool
var military_access_loss_behavior_option: RuleOptions
var is_trespassing_default: RuleBool
var can_enable_trespassing: RuleBool
var can_disable_trespassing: RuleBool
var can_ask_to_stop_trespassing: RuleBool
var automatically_fight_trespassers: RuleBool
var is_fighting_default: RuleBool
var can_enable_fighting: RuleBool
var can_disable_fighting: RuleBool
var can_ask_to_stop_fighting: RuleBool
var automatically_fight_back: RuleBool

# Categories
var _category_game_over: RuleItem
var _category_recruitment: RuleItem
var _category_population: RuleItem
var _category_fortresses: RuleItem
var _category_battle: RuleItem
var _category_ai: RuleItem
var _category_ai_type: RuleItem
var _category_ai_personality: RuleItem
var _category_diplomacy: RuleItem
var _category_diplomacy_data: RuleItem
var _category_diplomacy_military_access: RuleItem
var _category_diplomacy_trespassing: RuleItem
var _category_diplomacy_fighting: RuleItem

# 4.0 Backwards compatibility
var reinforcements_random_range: RuleRangeInt
var province_income_random_range: RuleRangeInt

## The rule items that are not a subrule of any other rule.
## All of the rules should be recursively contained within these root rules.
## This is used to define the layout of the rule interface.
## See also: [RuleRootNode]
var root_rules: Array[RuleItem] = []


func _init() -> void:
	# Define the default rules & rule layout here
	# TODO this is kinda cursed I guess
	turn_limit_enabled = RuleBool.new()
	turn_limit = RuleInt.new()
	game_over_provinces_owned_option = RuleOptions.new()
	game_over_provinces_owned_constant = RuleInt.new()
	game_over_provinces_owned_percentage = RuleFloat.new()
	reinforcements_enabled = RuleBool.new()
	reinforcements_option = RuleOptions.new()
	reinforcements_random_min = RuleInt.new()
	reinforcements_random_max = RuleInt.new()
	reinforcements_constant = RuleInt.new()
	reinforcements_per_person = RuleFloat.new()
	recruitment_enabled = RuleBool.new()
	recruitment_money_per_unit = RuleFloat.new()
	recruitment_population_per_unit = RuleFloat.new()
	population_growth_enabled = RuleBool.new()
	population_growth_rate = RuleFloat.new()
	extra_starting_population = RuleInt.new()
	start_with_fortress = RuleBool.new()
	build_fortress_enabled = RuleBool.new()
	fortress_price = RuleInt.new()
	starting_money = RuleInt.new()
	province_income_option = RuleOptions.new()
	province_income_random_min = RuleInt.new()
	province_income_random_max = RuleInt.new()
	province_income_constant = RuleInt.new()
	province_income_per_person = RuleFloat.new()
	minimum_army_size = RuleInt.new()
	global_attacker_efficiency = RuleFloat.new()
	global_defender_efficiency = RuleFloat.new()
	battle_algorithm_option = RuleOptions.new()
	default_ai_type = RuleInt.new()
	start_with_random_ai_type = RuleBool.new()
	default_ai_personality_option = RuleOptions.new()
	start_with_random_ai_personality = RuleBool.new()
	diplomacy_presets_option = RuleOptions.new()
	starts_with_random_relationship_preset = RuleBool.new()
	grants_military_access_default = RuleBool.new()
	can_grant_military_access = RuleBool.new()
	can_revoke_military_access = RuleBool.new()
	can_ask_for_military_access = RuleBool.new()
	is_military_access_mutual = RuleBool.new()
	is_military_access_revoked_when_fighting = RuleBool.new()
	military_access_loss_behavior_option = RuleOptions.new()
	is_trespassing_default = RuleBool.new()
	can_enable_trespassing = RuleBool.new()
	can_disable_trespassing = RuleBool.new()
	can_ask_to_stop_trespassing = RuleBool.new()
	automatically_fight_trespassers = RuleBool.new()
	is_fighting_default = RuleBool.new()
	can_enable_fighting = RuleBool.new()
	can_disable_fighting = RuleBool.new()
	can_ask_to_stop_fighting = RuleBool.new()
	automatically_fight_back = RuleBool.new()
	_category_game_over = RuleItem.new()
	_category_recruitment = RuleItem.new()
	_category_population = RuleItem.new()
	_category_fortresses = RuleItem.new()
	_category_battle = RuleItem.new()
	_category_ai = RuleItem.new()
	_category_ai_type = RuleItem.new()
	_category_ai_personality = RuleItem.new()
	_category_diplomacy = RuleItem.new()
	_category_diplomacy_data = RuleItem.new()
	_category_diplomacy_military_access = RuleItem.new()
	_category_diplomacy_trespassing = RuleItem.new()
	_category_diplomacy_fighting = RuleItem.new()
	reinforcements_random_range = RuleRangeInt.new()
	province_income_random_range = RuleRangeInt.new()
	
	turn_limit_enabled.text = "Turn limit"
	turn_limit_enabled.value = false
	turn_limit_enabled.sub_rules = [turn_limit]
	turn_limit_enabled.sub_rules_on = [0]
	
	turn_limit.text = "Final turn"
	turn_limit.minimum = 1
	turn_limit.has_minimum = true
	turn_limit.value = 50
	
	game_over_provinces_owned_option.text = "Number of controlled provinces"
	game_over_provinces_owned_option.options = [
		"Disabled",
		"Constant",
		"Percentage of world",
	]
	game_over_provinces_owned_option.selected = 2
	game_over_provinces_owned_option.sub_rules = [
		game_over_provinces_owned_constant,
		game_over_provinces_owned_percentage,
	]
	game_over_provinces_owned_option.option_filters = [[], [0], [1]]
	
	game_over_provinces_owned_constant.text = "Amount"
	game_over_provinces_owned_constant.minimum = 0
	game_over_provinces_owned_constant.has_minimum = true
	game_over_provinces_owned_constant.value = 40
	
	game_over_provinces_owned_percentage.text = "Percentage"
	game_over_provinces_owned_percentage.is_percentage = true
	game_over_provinces_owned_percentage.minimum = 0.0
	game_over_provinces_owned_percentage.has_minimum = true
	game_over_provinces_owned_percentage.maximum = 1.0
	game_over_provinces_owned_percentage.has_maximum = true
	game_over_provinces_owned_percentage.value = 0.7
	
	reinforcements_enabled.text = "Reinforcements at the start of each turn"
	reinforcements_enabled.value = true
	reinforcements_enabled.sub_rules = [
		reinforcements_option,
	]
	reinforcements_enabled.sub_rules_on = [0]
	
	reinforcements_option.text = "Reinforcements size"
	reinforcements_option.options = [
		"Random", "Constant", "Proportional to population size"
	]
	reinforcements_option.selected = 2
	reinforcements_option.sub_rules = [
		reinforcements_random_range,
		reinforcements_constant,
		reinforcements_per_person,
	]
	reinforcements_option.option_filters = [[0], [1], [2]]
	
	reinforcements_random_min.text = "Minimum"
	reinforcements_random_min.minimum = 0
	reinforcements_random_min.has_minimum = true
	reinforcements_random_min.value = 10
	
	reinforcements_random_max.text = "Maximum"
	reinforcements_random_max.minimum = 0
	reinforcements_random_max.has_minimum = true
	reinforcements_random_max.value = 40
	
	reinforcements_constant.text = "Amount"
	reinforcements_constant.minimum = 0
	reinforcements_constant.has_minimum = true
	reinforcements_constant.value = 20
	
	reinforcements_per_person.text = "Amount per person"
	reinforcements_per_person.minimum = 0
	reinforcements_per_person.has_minimum = true
	reinforcements_per_person.value = 0.4
	
	recruitment_enabled.text = "Can recruit new armies"
	recruitment_enabled.value = true
	recruitment_enabled.sub_rules = [
		recruitment_money_per_unit,
		recruitment_population_per_unit,
	]
	recruitment_enabled.sub_rules_on = [0, 1]
	
	recruitment_money_per_unit.text = "Money cost per unit"
	recruitment_money_per_unit.minimum = 0
	recruitment_money_per_unit.has_minimum = true
	recruitment_money_per_unit.value = 0.1
	
	recruitment_population_per_unit.text = "Population cost per unit"
	recruitment_population_per_unit.minimum = 0
	recruitment_population_per_unit.has_minimum = true
	recruitment_population_per_unit.value = 1.0
	
	population_growth_enabled.text = "Population growth"
	population_growth_enabled.value = true
	population_growth_enabled.sub_rules = [
		population_growth_rate,
	]
	population_growth_enabled.sub_rules_on = [0]
	
	population_growth_rate.text = "Growth rate"
	population_growth_rate.minimum = 0
	population_growth_rate.has_minimum = true
	population_growth_rate.value = 0.48
	
	extra_starting_population.text = "Extra population in starting province"
	extra_starting_population.minimum = 0
	extra_starting_population.has_minimum = true
	extra_starting_population.value = 0
	
	start_with_fortress.text = "Start with a fortress"
	start_with_fortress.value = true
	
	build_fortress_enabled.text = "Can be built"
	build_fortress_enabled.value = true
	build_fortress_enabled.sub_rules = [
		fortress_price,
	]
	build_fortress_enabled.sub_rules_on = [0]
	
	fortress_price.text = "Money cost"
	fortress_price.minimum = 0
	fortress_price.has_minimum = true
	fortress_price.value = 1000
	
	starting_money.text = "Starting money"
	starting_money.minimum = 0
	starting_money.has_minimum = true
	starting_money.value = 1000
	
	province_income_option.text = "Income from provinces"
	province_income_option.options = [
		"Random", "Constant", "Proportional to population size"
	]
	province_income_option.selected = 2
	province_income_option.sub_rules = [
		province_income_random_range,
		province_income_constant,
		province_income_per_person,
	]
	province_income_option.option_filters = [[0], [1], [2]]
	
	province_income_random_min.text = "Minimum"
	province_income_random_min.minimum = 0
	province_income_random_min.has_minimum = true
	province_income_random_min.value = 10
	
	province_income_random_max.text = "Maximum"
	province_income_random_max.minimum = 0
	province_income_random_max.has_minimum = true
	province_income_random_max.value = 100
	
	province_income_constant.text = "Amount"
	province_income_constant.minimum = 0
	province_income_constant.has_minimum = true
	province_income_constant.value = 100
	
	province_income_per_person.text = "Income per person"
	province_income_per_person.minimum = 0
	province_income_per_person.has_minimum = true
	province_income_per_person.value = 0.075
	
	minimum_army_size.text = "Minimum army size"
	minimum_army_size.minimum = 1
	minimum_army_size.has_minimum = true
	minimum_army_size.value = 1
	
	global_attacker_efficiency.text = "Global attacker efficiency"
	global_attacker_efficiency.minimum = 0
	global_attacker_efficiency.has_minimum = true
	global_attacker_efficiency.value = 0.9
	
	global_defender_efficiency.text = "Global defender efficiency"
	global_defender_efficiency.minimum = 0
	global_defender_efficiency.has_minimum = true
	global_defender_efficiency.value = 1.0
	
	battle_algorithm_option.text = "Algorithm"
	battle_algorithm_option.options = [
		"Standard", "Algorithm 2"
	]
	battle_algorithm_option.selected = 0
	
	default_ai_type.text = "Default AI type"
	default_ai_type.minimum = 0
	default_ai_type.has_minimum = true
	default_ai_type.maximum = 2
	default_ai_type.has_maximum = true
	default_ai_type.value = 2
	
	start_with_random_ai_type.text = "Players start with a random AI type"
	start_with_random_ai_type.value = false
	
	default_ai_personality_option.text = "Default AI personality"
	default_ai_personality_option.options = AIPersonality.all_type_names()
	default_ai_personality_option.selected = AIPersonality.DEFAULT_TYPE
	
	start_with_random_ai_personality.text = (
			"Players start with a random AI personality"
	)
	start_with_random_ai_personality.value = true
	
	diplomacy_presets_option.text = "Default preset"
	diplomacy_presets_option.options = [
		"Don't use presets", "Allied", "Neutral", "At war"
	]
	diplomacy_presets_option.selected = 2
	diplomacy_presets_option.sub_rules = [
		starts_with_random_relationship_preset,
		starts_with_random_relationship_preset,
		starts_with_random_relationship_preset,
	]
	diplomacy_presets_option.option_filters = [[], [0], [1], [2]]
	
	starts_with_random_relationship_preset.text = (
			"Countries start with a random relationship preset"
	)
	starts_with_random_relationship_preset.value = false
	
	grants_military_access_default.text = "Grant military access by default"
	grants_military_access_default.value = false
	
	can_grant_military_access.text = "Can manually grant military access"
	can_grant_military_access.value = false
	
	can_revoke_military_access.text = "Can manually revoke military access"
	can_revoke_military_access.value = false
	
	can_ask_for_military_access.text = "Can ask for military access"
	can_ask_for_military_access.value = false
	
	is_military_access_mutual.text = (
			"Countries automatically grant military access"
			+ " to whoever grants it to them"
	)
	is_military_access_mutual.value = false
	
	is_military_access_revoked_when_fighting.text = (
			"Automatically revoke military access when fighting"
	)
	is_military_access_revoked_when_fighting.value = true
	
	military_access_loss_behavior_option.text = (
			"What to do to armies that no longer have military access"
	)
	military_access_loss_behavior_option.options = [
		"No effect",
		"Delete the armies",
		"Teleport the armies to the nearest valid location",
	]
	military_access_loss_behavior_option.selected = 0
	
	is_trespassing_default.text = "Trespass in other countries by default"
	is_trespassing_default.value = true
	
	can_enable_trespassing.text = "Can manually start trespassing"
	can_enable_trespassing.value = false
	
	can_disable_trespassing.text = "Can manually stop trespassing"
	can_disable_trespassing.value = false
	
	can_ask_to_stop_trespassing.text = "Can ask to stop trespassing"
	can_ask_to_stop_trespassing.value = false
	
	automatically_fight_trespassers.text = (
			"Automatically start fighting trespassers"
	)
	automatically_fight_trespassers.value = true
	
	is_fighting_default.text = "Fight other countries by default"
	is_fighting_default.value = true
	
	can_enable_fighting.text = "Can manually start fighting"
	can_enable_fighting.value = false
	
	can_disable_fighting.text = "Can manually stop fighting"
	can_disable_fighting.value = false
	
	can_ask_to_stop_fighting.text = "Can ask to stop fighting"
	can_ask_to_stop_fighting.value = false
	
	automatically_fight_back.text = (
			"Countries automatically start fighting with whoever fights them"
	)
	automatically_fight_back.value = true
	
	_category_game_over.text = "Game Over conditions"
	_category_game_over.sub_rules = [
		turn_limit_enabled,
		game_over_provinces_owned_option,
	]
	
	_category_recruitment.text = "Recruitment"
	_category_recruitment.sub_rules = [
		reinforcements_enabled,
		recruitment_enabled,
	]
	
	_category_population.text = "Population"
	_category_population.sub_rules = [
		population_growth_enabled,
		extra_starting_population,
	]
	
	_category_fortresses.text = "Fortresses"
	_category_fortresses.sub_rules = [
		start_with_fortress,
		build_fortress_enabled,
	]
	
	_category_battle.text = "Battle"
	_category_battle.sub_rules = [
		global_attacker_efficiency,
		global_defender_efficiency,
		battle_algorithm_option,
	]
	
	_category_ai.text = "AI"
	_category_ai.sub_rules = [
		_category_ai_type,
		_category_ai_personality,
	]
	
	_category_ai_type.text = "AI type (the way it plays)"
	_category_ai_type.sub_rules = [
		default_ai_type,
		start_with_random_ai_type,
	]
	
	_category_ai_personality.text = (
			"AI personality (the way it behaves diplomatically)"
	)
	_category_ai_personality.sub_rules = [
		default_ai_personality_option,
		start_with_random_ai_personality,
	]
	
	_category_diplomacy.text = "Diplomacy"
	_category_diplomacy.sub_rules = [
		diplomacy_presets_option,
		_category_diplomacy_data,
	]
	
	_category_diplomacy_data.text = (
			"Relationship data (these may be overridden by presets)"
	)
	_category_diplomacy_data.sub_rules = [
		_category_diplomacy_military_access,
		_category_diplomacy_trespassing,
		_category_diplomacy_fighting,
	]
	
	_category_diplomacy_military_access.text = "Military access"
	_category_diplomacy_military_access.sub_rules = [
		grants_military_access_default,
		can_grant_military_access,
		can_revoke_military_access,
		can_ask_for_military_access,
		is_military_access_mutual,
		is_military_access_revoked_when_fighting,
		military_access_loss_behavior_option,
	]
	
	_category_diplomacy_trespassing.text = "Trespassing"
	_category_diplomacy_trespassing.sub_rules = [
		is_trespassing_default,
		can_enable_trespassing,
		can_disable_trespassing,
		can_ask_to_stop_trespassing,
		automatically_fight_trespassers,
	]
	
	_category_diplomacy_fighting.text = "Fighting"
	_category_diplomacy_fighting.sub_rules = [
		is_fighting_default,
		can_enable_fighting,
		can_disable_fighting,
		can_ask_to_stop_fighting,
		automatically_fight_back,
	]
	
	reinforcements_random_range.min_rule = reinforcements_random_min
	reinforcements_random_range.max_rule = reinforcements_random_max
	reinforcements_random_range.minimum = 0
	reinforcements_random_range.has_minimum = true
	reinforcements_random_range.min_value = 10
	reinforcements_random_range.max_value = 40
	
	province_income_random_range.min_rule = province_income_random_min
	province_income_random_range.max_rule = province_income_random_max
	province_income_random_range.minimum = 0
	province_income_random_range.has_minimum = true
	province_income_random_range.min_value = 10
	province_income_random_range.max_value = 100
	
	root_rules = [
		_category_game_over,
		_category_recruitment,
		_category_population,
		_category_fortresses,
		starting_money,
		province_income_option,
		minimum_army_size,
		_category_battle,
		_category_ai,
		_category_diplomacy,
	]


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	_connect_signals()


func all_rules() -> Array[RuleItem]:
	var output: Array[RuleItem] = []
	for rule_name in RULE_NAMES:
		output.append(rule_with_name(rule_name))
	return output


func rule_with_name(rule_name: String) -> RuleItem:
	if not RULE_NAMES.has(rule_name):
		push_warning('No rule with name "' + rule_name + '".')
		return null
	return get(rule_name) as RuleItem


## Returns a new deep copy of the game rules.
func copy() -> GameRules:
	return RulesFromDict.new().result(RulesToDict.new().result(self))


## Permanently prevents any of the rules from changing.
func lock() -> void:
	for rule in root_rules:
		rule.lock()


func _connect_signals() -> void:
	for rule_name in RULE_NAMES:
		var rule: RuleItem = rule_with_name(rule_name)
		if rule == null:
			continue
		if rule.has_signal("value_changed"):
			rule.connect("value_changed", _on_rule_value_changed)
		else:
			push_error('Rule does not have a "value_changed" signal')


func _name_of_rule(rule_item: RuleItem) -> String:
	for rule_name in RULE_NAMES:
		if rule_with_name(rule_name) == rule_item:
			return rule_name
	push_error("Cannot find the rule's name.")
	return ""


## Sets the value of a given rule by its string name,
## for the purpose of network synchronization.
func _set_rule(rule_name: String, value: Variant) -> void:
	var rule_item: RuleItem = rule_with_name(rule_name)
	if rule_item == null:
		return
	rule_item.set_data(value)


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
		push_warning("Received server request, but you're not the server.")
		return
	_receive_all_data.rpc(RulesToDict.new().result(self))


@rpc("authority", "call_remote", "reliable")
func _receive_all_data(data: Dictionary) -> void:
	for rule_name: String in data.keys():
		_set_rule(rule_name, data.get(rule_name))
#endregion


#region Synchronize one specific rule
## The server calls this to inform clients of a rule change.
## This function has no effect if you're not connected as a server.
func _send_rule_change_to_clients(rule_item: RuleItem) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	_receive_rule_change.rpc(_name_of_rule(rule_item), rule_item.get_data())


@rpc("authority", "call_remote", "reliable")
func _receive_rule_change(rule_name: String, value: Variant) -> void:
	_set_rule(rule_name, value)
#endregion


func _on_rule_value_changed(rule_item: RuleItem) -> void:
	_send_rule_change_to_clients(rule_item)


func _on_connected_to_server() -> void:
	_request_all_data()
