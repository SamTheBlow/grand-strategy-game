class_name RuleInterface
extends MarginContainer
## Base class. Displays information about a game rule.
## Displays a rule's subrules recursively with indentation.
##
## See also: [GameRules]


## The number of pixels between each rule node.
@export var spacing_px: int = 8
## The number of pixels for each tab.
@export var tabbing_px: int = 64

@export var scenes: RuleScenes

@onready var _container := %Container as Control


func _add_sub_rules(
		sub_rules: Array[RuleItem],
		with_spacing: bool = false,
		with_tabbing: bool = true
) -> void:
	if not scenes:
		push_error("Rule interface was not given scenes.")
		return
	
	for sub_rule in sub_rules:
		if sub_rule is RuleInt:
			var rule_node := (
					scenes.rule_int_scene.instantiate() as RuleIntNode
			)
			rule_node.scenes = scenes
			rule_node.rule = sub_rule as RuleInt
			_add_rule(rule_node, with_spacing, with_tabbing)
		elif sub_rule is RuleFloat:
			var rule_node := (
					scenes.rule_float_scene.instantiate() as RuleFloatNode
			)
			rule_node.scenes = scenes
			rule_node.rule = sub_rule as RuleFloat
			_add_rule(rule_node, with_spacing, with_tabbing)
		elif sub_rule is RuleBool:
			var rule_node := (
					scenes.rule_boolean_scene.instantiate() as RuleBoolNode
			)
			rule_node.scenes = scenes
			rule_node.rule = sub_rule as RuleBool
			_add_rule(rule_node, with_spacing, with_tabbing)
		elif sub_rule is RuleOptions:
			var rule_node := (
					scenes.rule_options_scene.instantiate() as RuleOptionsNode
			)
			rule_node.scenes = scenes
			rule_node.rule = sub_rule as RuleOptions
			_add_rule(rule_node, with_spacing, with_tabbing)
		elif sub_rule is RuleRangeInt:
			var rule_node := (
					scenes.rule_range_int_scene.instantiate()
					as RuleRangeIntNode
			)
			rule_node.scenes = scenes
			rule_node.rule = sub_rule as RuleRangeInt
			_add_rule(rule_node, with_spacing, with_tabbing)
		elif sub_rule is RuleRangeFloat:
			var rule_node := (
					scenes.rule_range_float_scene.instantiate()
					as RuleRangeFloatNode
			)
			rule_node.scenes = scenes
			rule_node.rule = sub_rule as RuleRangeFloat
			_add_rule(rule_node, with_spacing, with_tabbing)
		else:
			var rule_node := (
					scenes.rule_category_scene.instantiate()
					as RuleCategoryNode
			)
			rule_node.scenes = scenes
			rule_node.rule = sub_rule
			_add_rule(rule_node, with_spacing, with_tabbing)


func _add_rule(
		rule_node: RuleInterface,
		with_spacing: bool = false,
		with_tabbing: bool = true
) -> void:
	if with_spacing:
		var number_of_children: int = _container.get_children().size()
		if number_of_children > 0:
			var spacing := Control.new()
			spacing.name = "Spacing" + str(number_of_children)
			spacing.custom_minimum_size.y = spacing_px
			_container.add_child(spacing)
	
	var h_box_container := HBoxContainer.new()
	_container.add_child(h_box_container)
	
	if with_tabbing:
		var tabbing := Control.new()
		tabbing.name = "Tabbing"
		tabbing.custom_minimum_size.x = tabbing_px
		h_box_container.add_child(tabbing)
	
	h_box_container.add_child(rule_node)
