class_name GameRules
## Defines all the details on how a [Game] is to be played.
## This is just a data structure; it cannot enforce rules on its own.
## The different objects in the game must carefully read this object's
## properties in order to behave correctly.
##
## This class also defines the rule layout
## for visual representation of the rules in a menu.

signal rule_changed(rule_name: String, rule_item: PropertyTreeItem)

## All of the individual rules.
## They must all point to a property in this class of type [PropertyTreeItem],
## and all of these [PropertyTreeItem]s must have a "value" property
## as well as a "value_changed" signal. This signal must
## pass itself (a [PropertyTreeItem]) as the only argument.
const RULE_NAMES: Array[String] = [
	"rng_seed_override_enabled",
	"rng_seed",
	"recruitment_enabled",
	"recruitment_money_per_unit",
	"recruitment_population_per_unit",
	"minimum_army_size",
	"maximum_army_size",
	"global_attacker_efficiency",
	"global_defender_efficiency",
	"battle_algorithm_option",
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
var rng_seed_override_enabled := ItemBool.new()
var rng_seed := ItemString.new()
var recruitment_enabled := ItemBool.new()
var recruitment_money_per_unit := ItemFloat.new()
var recruitment_population_per_unit := ItemFloat.new()
var minimum_army_size := ItemInt.new()
var maximum_army_size := ItemInt.new()
var global_attacker_efficiency := ItemFloat.new()
var global_defender_efficiency := ItemFloat.new()
var battle_algorithm_option := ItemOptions.new()
# Categories
var _category_recruitment := PropertyTreeItem.new()
var _category_battle := PropertyTreeItem.new()

## The rule items that are not a subrule of any other rule.
## All of the rules should be recursively contained within these root rules.
## This is used to define the layout of the rule interface.
## See also: [RulesMenu]
var root_rules: Array[PropertyTreeItem] = []


# Defines the default rules & rule layout
# TODO this is kinda cursed I guess
func _init() -> void:
	rng_seed_override_enabled.text = "Override RNG seed"
	rng_seed_override_enabled.value = false
	rng_seed_override_enabled.child_items = [rng_seed]
	rng_seed_override_enabled.child_items_on = [0]

	rng_seed.text = "Seed"
	rng_seed.placeholder_text = "(Random)"
	rng_seed.value = ""

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

	minimum_army_size.text = "Minimum army size"
	minimum_army_size.minimum = 1
	minimum_army_size.has_minimum = true
	minimum_army_size.value = 1

	maximum_army_size.text = "Maximum army size"
	maximum_army_size.minimum = -1
	maximum_army_size.has_minimum = true
	maximum_army_size.value = -1

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

	_category_recruitment.text = "Recruitment"
	_category_recruitment.child_items = [
		recruitment_enabled,
	]

	_category_battle.text = "Battle"
	_category_battle.child_items = [
		global_attacker_efficiency,
		global_defender_efficiency,
		battle_algorithm_option,
	]

	root_rules = [
		rng_seed_override_enabled,
		_category_recruitment,
		minimum_army_size,
		maximum_army_size,
		_category_battle,
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


func _connect_signals() -> void:
	for rule_name in RULE_NAMES:
		var rule: PropertyTreeItem = rule_with_name(rule_name)
		if rule == null:
			push_error("Rule is null.")
			continue
		if rule.has_signal(&"value_changed"):
			rule.connect(
					&"value_changed",
					_on_rule_value_changed.unbind(1),
					ConnectFlags.CONNECT_APPEND_SOURCE_OBJECT
			)
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
