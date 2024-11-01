class_name RulesMenu
extends RuleInterface


@export var game_rules: GameRules:
	set(value):
		game_rules = value
		_add_sub_rules(game_rules.root_rules, true, false)
