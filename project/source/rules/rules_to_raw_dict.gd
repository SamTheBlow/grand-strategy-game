class_name RulesToRawDict
## Converts a [GameRules] into a raw [Dictionary].
##
## This operation always succeeds.
##
## See also: [RulesFromRaw]


static func parsed_from(game_rules: GameRules) -> Dictionary:
	var default_rules := GameRules.new()

	var rules_dict: Dictionary = {}
	for rule_name in GameRules.RULE_NAMES:
		var rule_value: Variant = (
				game_rules.rule_with_name(rule_name).get_data()
		)
		var default_value: Variant = (
				default_rules.rule_with_name(rule_name).get_data()
		)

		if rule_value == default_value:
			continue

		rules_dict[rule_name] = rule_value

	return rules_dict
