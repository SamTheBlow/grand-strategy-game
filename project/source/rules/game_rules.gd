class_name GameRules
## Defines all the details on how a [Game] is to be played.
## This is just a data structure; it cannot enforce rules on its own.
## The different objects in the game must carefully read this object's
## properties in order to behave correctly.
##
## This class also defines the rule layout
## for visual representation of the rules in a menu.

signal rule_changed(rule_name: String, rule_item: PropertyTreeItem)

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

enum GameOverProvincesOwnedOption {
	DISABLED = 0,
	CONSTANT = 1,
	PERCENTAGE = 2,
}

## All of the individual rules.
## They must all point to a property in this class of type [PropertyTreeItem],
## and all of these [PropertyTreeItem]s must have a "value" property
## as well as a "value_changed" signal. This signal must
## pass itself (a [PropertyTreeItem]) as the only argument.
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
	"random_population_enabled",
	"population_growth_enabled",
	"population_growth_rate",
	"extra_starting_population",
	"start_with_fortress",
	"build_fortress_enabled",
	"fortress_price",
	"starting_money",
	"province_income_override_enabled",
	"province_income_option",
	"province_income_random_min",
	"province_income_random_max",
	"province_income_constant",
	"province_income_per_person",
	"minimum_army_size",
	"starting_army_size",
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

# TODO duplicate the resources and/or change how they're loaded entirely
var diplomatic_presets := DiplomacyPresets.new([
	preload("uid://coqnkgbae8r7r"),
	preload("uid://c8mdgpc7c41f5"),
	preload("uid://drsaelw08l4l5"),
])
var diplomatic_actions := DiplomacyActionDefinitions.new([
	load("uid://i0e1lhoyfteg") as DiplomacyActionDefinition,
	load("uid://c3kj2ppbkeuk6") as DiplomacyActionDefinition,
	load("uid://yw0vmi0myodt") as DiplomacyActionDefinition,
	load("uid://bke4orh12nfe5") as DiplomacyActionDefinition,
	load("uid://d1vcmgrvxolht") as DiplomacyActionDefinition,
	load("uid://bw7wow17qy2hc") as DiplomacyActionDefinition,
	load("uid://j3xl6wxmu3el") as DiplomacyActionDefinition,
	load("uid://cf45nbq3o1no7") as DiplomacyActionDefinition,
	load("uid://mqdrxwhb0kie") as DiplomacyActionDefinition,
	load("uid://cjxq7pod7pt0u") as DiplomacyActionDefinition,
	load("uid://1xq5bfaikpwu") as DiplomacyActionDefinition,
	load("uid://bp5csoje1ocde") as DiplomacyActionDefinition,
	load("uid://dvdfnj3lic55") as DiplomacyActionDefinition,
])
var battle: Battle = preload("uid://cuylrn1evjy6r")

# Individual rules
var turn_limit_enabled := ItemBool.new()
var turn_limit := ItemInt.new()
var game_over_provinces_owned_option := ItemOptions.new()
var game_over_provinces_owned_constant := ItemInt.new()
var game_over_provinces_owned_percentage := ItemFloat.new()
var reinforcements_enabled := ItemBool.new()
var reinforcements_option := ItemOptions.new()
var reinforcements_random_min := ItemInt.new()
var reinforcements_random_max := ItemInt.new()
var reinforcements_constant := ItemInt.new()
var reinforcements_per_person := ItemFloat.new()
var recruitment_enabled := ItemBool.new()
var recruitment_money_per_unit := ItemFloat.new()
var recruitment_population_per_unit := ItemFloat.new()
var random_population_enabled := ItemBool.new()
var population_growth_enabled := ItemBool.new()
var population_growth_rate := ItemFloat.new()
var extra_starting_population := ItemInt.new()
var start_with_fortress := ItemBool.new()
var build_fortress_enabled := ItemBool.new()
var fortress_price := ItemInt.new()
var starting_money := ItemInt.new()
var province_income_override_enabled := ItemBool.new()
var province_income_option := ItemOptions.new()
var province_income_random_min := ItemInt.new()
var province_income_random_max := ItemInt.new()
var province_income_constant := ItemInt.new()
var province_income_per_person := ItemFloat.new()
var minimum_army_size := ItemInt.new()
var starting_army_size := ItemInt.new()
var global_attacker_efficiency := ItemFloat.new()
var global_defender_efficiency := ItemFloat.new()
var battle_algorithm_option := ItemOptions.new()
var default_ai_type := ItemInt.new()
var start_with_random_ai_type := ItemBool.new()
var default_ai_personality_option := ItemOptions.new()
var start_with_random_ai_personality := ItemBool.new()
var diplomacy_presets_option := ItemOptions.new()
var starts_with_random_relationship_preset := ItemBool.new()
var grants_military_access_default := ItemBool.new()
var can_grant_military_access := ItemBool.new()
var can_revoke_military_access := ItemBool.new()
var can_ask_for_military_access := ItemBool.new()
var is_military_access_mutual := ItemBool.new()
var is_military_access_revoked_when_fighting := ItemBool.new()
var military_access_loss_behavior_option := ItemOptions.new()
var is_trespassing_default := ItemBool.new()
var can_enable_trespassing := ItemBool.new()
var can_disable_trespassing := ItemBool.new()
var can_ask_to_stop_trespassing := ItemBool.new()
var automatically_fight_trespassers := ItemBool.new()
var is_fighting_default := ItemBool.new()
var can_enable_fighting := ItemBool.new()
var can_disable_fighting := ItemBool.new()
var can_ask_to_stop_fighting := ItemBool.new()
var automatically_fight_back := ItemBool.new()

# Categories
var _category_game_over := PropertyTreeItem.new()
var _category_recruitment := PropertyTreeItem.new()
var _category_population := PropertyTreeItem.new()
var _category_fortresses := PropertyTreeItem.new()
var _category_battle := PropertyTreeItem.new()
var _category_ai := PropertyTreeItem.new()
var _category_ai_type := PropertyTreeItem.new()
var _category_ai_personality := PropertyTreeItem.new()
var _category_diplomacy := PropertyTreeItem.new()
var _category_diplomacy_data := PropertyTreeItem.new()
var _category_diplomacy_military_access := PropertyTreeItem.new()
var _category_diplomacy_trespassing := PropertyTreeItem.new()
var _category_diplomacy_fighting := PropertyTreeItem.new()

# 4.0 Backwards compatibility
var reinforcements_random_range := ItemRangeInt.new()
var province_income_random_range := ItemRangeInt.new()

## The rule items that are not a subrule of any other rule.
## All of the rules should be recursively contained within these root rules.
## This is used to define the layout of the rule interface.
## See also: [RulesMenu]
var root_rules: Array[PropertyTreeItem] = []


# Defines the default rules & rule layout
# TODO this is kinda cursed I guess
func _init() -> void:
	turn_limit_enabled.text = "Turn limit"
	turn_limit_enabled.value = false
	turn_limit_enabled.child_items = [turn_limit]
	turn_limit_enabled.child_items_on = [0]

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
	game_over_provinces_owned_option.selected_index = 2
	game_over_provinces_owned_option.child_items = [
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
	reinforcements_enabled.child_items = [
		reinforcements_option,
	]
	reinforcements_enabled.child_items_on = [0]

	reinforcements_option.text = "Reinforcements size"
	reinforcements_option.options = [
		"Random", "Constant", "Proportional to population size"
	]
	reinforcements_option.selected_index = 2
	reinforcements_option.child_items = [
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
	recruitment_enabled.child_items = [
		recruitment_money_per_unit,
		recruitment_population_per_unit,
	]
	recruitment_enabled.child_items_on = [0, 1]

	recruitment_money_per_unit.text = "Money cost per unit"
	recruitment_money_per_unit.minimum = 0
	recruitment_money_per_unit.has_minimum = true
	recruitment_money_per_unit.value = 0.1

	recruitment_population_per_unit.text = "Population cost per unit"
	recruitment_population_per_unit.minimum = 0
	recruitment_population_per_unit.has_minimum = true
	recruitment_population_per_unit.value = 1.0

	random_population_enabled.text = "Randomize populations at the start"
	random_population_enabled.value = true

	population_growth_enabled.text = "Population growth"
	population_growth_enabled.value = true
	population_growth_enabled.child_items = [
		population_growth_rate,
	]
	population_growth_enabled.child_items_on = [0]

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
	build_fortress_enabled.child_items = [
		fortress_price,
	]
	build_fortress_enabled.child_items_on = [0]

	fortress_price.text = "Money cost"
	fortress_price.minimum = 0
	fortress_price.has_minimum = true
	fortress_price.value = 1000

	starting_money.text = "Starting money"
	starting_money.minimum = 0
	starting_money.has_minimum = true
	starting_money.value = 1000

	province_income_override_enabled.text = "Enforce specific province income"
	province_income_override_enabled.value = true
	province_income_override_enabled.child_items = [
		province_income_option,
	]
	province_income_override_enabled.child_items_on = [0]

	province_income_option.text = "Income from provinces"
	province_income_option.options = [
		"Random", "Constant", "Proportional to population size"
	]
	province_income_option.selected_index = 2
	province_income_option.child_items = [
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

	starting_army_size.text = "Starting army size"
	starting_army_size.minimum = 0
	starting_army_size.has_minimum = true
	starting_army_size.value = 1000

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
	battle_algorithm_option.selected_index = 0

	default_ai_type.text = "Default AI type"
	default_ai_type.minimum = 0
	default_ai_type.has_minimum = true
	default_ai_type.maximum = 2
	default_ai_type.has_maximum = true
	default_ai_type.value = 2

	start_with_random_ai_type.text = "Players start with a random AI type"
	start_with_random_ai_type.value = false

	default_ai_personality_option.text = "Default AI personality"
	default_ai_personality_option.options = AIPersonality.type_names()
	default_ai_personality_option.option_value_map = AIPersonality.type_values()
	default_ai_personality_option.selected_index = (
			default_ai_personality_option
			.index_of_value(AIPersonality.DEFAULT_TYPE)
	)

	start_with_random_ai_personality.text = (
			"Players start with a random AI personality"
	)
	start_with_random_ai_personality.value = true

	diplomacy_presets_option.text = "Default preset"
	diplomacy_presets_option.options = [
		"Don't use presets", "Allied", "Neutral", "At war"
	]
	diplomacy_presets_option.selected_index = 2
	diplomacy_presets_option.child_items = [
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
	military_access_loss_behavior_option.selected_index = 0

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
	_category_game_over.child_items = [
		turn_limit_enabled,
		game_over_provinces_owned_option,
	]

	_category_recruitment.text = "Recruitment"
	_category_recruitment.child_items = [
		reinforcements_enabled,
		recruitment_enabled,
	]

	_category_population.text = "Population"
	_category_population.child_items = [
		random_population_enabled,
		population_growth_enabled,
		extra_starting_population,
	]

	_category_fortresses.text = "Fortresses"
	_category_fortresses.child_items = [
		start_with_fortress,
		build_fortress_enabled,
	]

	_category_battle.text = "Battle"
	_category_battle.child_items = [
		global_attacker_efficiency,
		global_defender_efficiency,
		battle_algorithm_option,
	]

	_category_ai.text = "AI"
	_category_ai.child_items = [
		_category_ai_type,
		_category_ai_personality,
	]

	_category_ai_type.text = "AI type (the way it plays)"
	_category_ai_type.child_items = [
		default_ai_type,
		start_with_random_ai_type,
	]

	_category_ai_personality.text = (
			"AI personality (the way it behaves diplomatically)"
	)
	_category_ai_personality.child_items = [
		default_ai_personality_option,
		start_with_random_ai_personality,
	]

	_category_diplomacy.text = "Diplomacy"
	_category_diplomacy.child_items = [
		diplomacy_presets_option,
		_category_diplomacy_data,
	]

	_category_diplomacy_data.text = (
			"Relationship data (these may be overridden by presets)"
	)
	_category_diplomacy_data.child_items = [
		_category_diplomacy_military_access,
		_category_diplomacy_trespassing,
		_category_diplomacy_fighting,
	]

	_category_diplomacy_military_access.text = "Military access"
	_category_diplomacy_military_access.child_items = [
		grants_military_access_default,
		can_grant_military_access,
		can_revoke_military_access,
		can_ask_for_military_access,
		is_military_access_mutual,
		is_military_access_revoked_when_fighting,
		military_access_loss_behavior_option,
	]

	_category_diplomacy_trespassing.text = "Trespassing"
	_category_diplomacy_trespassing.child_items = [
		is_trespassing_default,
		can_enable_trespassing,
		can_disable_trespassing,
		can_ask_to_stop_trespassing,
		automatically_fight_trespassers,
	]

	_category_diplomacy_fighting.text = "Fighting"
	_category_diplomacy_fighting.child_items = [
		is_fighting_default,
		can_enable_fighting,
		can_disable_fighting,
		can_ask_to_stop_fighting,
		automatically_fight_back,
	]

	reinforcements_random_range.min_item = reinforcements_random_min
	reinforcements_random_range.max_item = reinforcements_random_max
	reinforcements_random_range.minimum = 0
	reinforcements_random_range.has_minimum = true
	reinforcements_random_range.min_value = 10
	reinforcements_random_range.max_value = 40

	province_income_random_range.min_item = province_income_random_min
	province_income_random_range.max_item = province_income_random_max
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
		province_income_override_enabled,
		minimum_army_size,
		starting_army_size,
		_category_battle,
		_category_ai,
		_category_diplomacy,
	]

	_connect_signals()


func all_rules() -> Array[PropertyTreeItem]:
	var output: Array[PropertyTreeItem] = []
	for rule_name in RULE_NAMES:
		output.append(rule_with_name(rule_name))
	return output


## Returns null if there is no rule with given name.
func rule_with_name(rule_name: String) -> PropertyTreeItem:
	if not RULE_NAMES.has(rule_name):
		push_warning('No rule with name "' + rule_name + '".')
		return null
	return get(rule_name) as PropertyTreeItem


## Returns a new deep copy of the game rules.
func copy() -> GameRules:
	return RuleParsing.from_raw_data(RuleParsing.to_raw_dict(self))


## Permanently prevents any of the rules from changing.
func lock() -> void:
	for rule in root_rules:
		rule.lock()


func is_diplomacy_presets_enabled() -> bool:
	return diplomacy_presets_option.selected_value() != 0


func _connect_signals() -> void:
	for rule_name in RULE_NAMES:
		var rule: PropertyTreeItem = rule_with_name(rule_name)
		if rule == null:
			push_error("Rule is null.")
			continue
		if rule.has_signal("value_changed"):
			rule.connect("value_changed", _on_rule_value_changed)
		else:
			push_error('Rule does not have a "value_changed" signal.')


func _name_of_rule(rule_item: PropertyTreeItem) -> String:
	for rule_name in RULE_NAMES:
		if rule_with_name(rule_name) == rule_item:
			return rule_name
	push_error("Cannot find the rule's name.")
	return ""


## Sets the value of a given rule by its string name,
## for the purpose of network synchronization.
func _set_rule(rule_name: String, value: Variant) -> void:
	var rule_item: PropertyTreeItem = rule_with_name(rule_name)
	if rule_item == null:
		return
	rule_item.set_data(value)


func _on_rule_value_changed(rule_item: PropertyTreeItem) -> void:
	rule_changed.emit(_name_of_rule(rule_item), rule_item)
