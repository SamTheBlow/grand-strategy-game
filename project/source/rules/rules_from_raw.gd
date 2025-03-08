class_name RulesFromRaw
## Converts raw data into a [GameRules].
##
## This operation always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.
##
## See also: [RulesToRawDict]


static func parsed_from(raw_data: Variant) -> GameRules:
	var game_rules := GameRules.new()

	if raw_data is not Dictionary:
		return game_rules
	var raw_dict: Dictionary = raw_data

	for variant_key: Variant in raw_dict:
		if variant_key is not String:
			continue
		var key: String = variant_key

		if not key in GameRules.RULE_NAMES:
			continue

		# Make sure the value is the correct type.
		# If not, just ignore it and keep going.
		# Integers and floats are interchangeable.
		var rule_type: int = typeof(game_rules.rule_with_name(key).get_data())
		if rule_type == TYPE_INT:
			rule_type = TYPE_FLOAT
		var data_type: int = typeof(raw_dict[key])
		if data_type == TYPE_INT:
			data_type = TYPE_FLOAT
		if data_type != rule_type:
			continue

		game_rules.rule_with_name(key).set_data(raw_dict[key])

	return game_rules
