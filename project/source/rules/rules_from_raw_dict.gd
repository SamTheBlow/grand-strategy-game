class_name RulesFromRawDict
## Converts raw data into a new [GameRules] resource.
##
## See also: [RulesToRawDict]


## Note that calling this function with an empty dictionary
## is equivalent to creating a new instance of [GameRules].
func result(data_dict: Dictionary) -> GameRules:
	var game_rules := GameRules.new()

	for variant_key: Variant in data_dict.keys():
		if variant_key is not String:
			continue
		var key := variant_key as String

		if not key in GameRules.RULE_NAMES:
			continue

		# Make sure the value is the correct type.
		# If not, just ignore it and keep going.
		# Integers and floats are interchangeable.
		var rule_type: int = typeof(game_rules.rule_with_name(key).get_data())
		if rule_type == TYPE_INT:
			rule_type = TYPE_FLOAT
		var data_type: int = typeof(data_dict[key])
		if data_type == TYPE_INT:
			data_type = TYPE_FLOAT
		if data_type != rule_type:
			continue

		game_rules.rule_with_name(key).set_data(data_dict[key])

	return game_rules
