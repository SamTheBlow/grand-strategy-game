class_name RuleParsing
## Parses raw data from/to a [GameRules] instance.


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(raw_data: Variant) -> GameRules:
	var game_rules := GameRules.new()

	if raw_data is not Dictionary:
		return game_rules
	var raw_dict: Dictionary = raw_data

	for variant_key: Variant in raw_dict:
		if variant_key is not String:
			continue
		var key: String = variant_key

		if key not in GameRules.RULE_NAMES:
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


static func to_raw_dict(game_rules: GameRules) -> Dictionary:
	# Get the default rules to detect default values
	var default_rules := GameRules.new()

	var output: Dictionary = {}
	for rule_name in GameRules.RULE_NAMES:
		var rule_value: Variant = (
				game_rules.rule_with_name(rule_name).get_data()
		)
		var default_value: Variant = (
				default_rules.rule_with_name(rule_name).get_data()
		)

		if rule_value == default_value:
			continue

		output[rule_name] = rule_value

	return output
