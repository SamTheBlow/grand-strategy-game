class_name RulesToDict
## Converts a [GameRules] resource into raw data.


func result(game_rules: GameRules) -> Dictionary:
	var rules_dict: Dictionary = {}
	for rule_name in GameRules.RULE_NAMES:
		rules_dict[rule_name] = game_rules.rule_with_name(rule_name).get_data()
	return rules_dict
