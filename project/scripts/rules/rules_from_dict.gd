class_name RulesFromDict
## Turns given Dictionary data into a brand new [GameRules] object.


func result(data_dict: Dictionary) -> GameRules:
	var game_rules := GameRules.new()
	for key in GameRules.RULE_NAMES:
		# If the rule isn't there, that's ok, just use the default
		if not data_dict.has(key):
			continue
		
		# Make sure the value is the correct type
		# If not, just ignore it and keep going
		var rule_type: int = typeof(game_rules.rule_with_name(key).get_data())
		if rule_type == TYPE_INT:
			rule_type = TYPE_FLOAT
		var data_type: int = typeof(data_dict[key])
		if data_type == TYPE_INT:
			data_type = TYPE_FLOAT
		if data_type != rule_type:
			continue
		
		game_rules.rule_with_name(key).set_data(data_dict[key])
	
	# TODO temporary. remove later
	game_rules.diplomatic_actions = [
		load("res://resources/diplomacy/actions/break_alliance.tres"),
		load("res://resources/diplomacy/actions/declare_war.tres"),
		load("res://resources/diplomacy/actions/offer_alliance.tres"),
		load("res://resources/diplomacy/actions/offer_peace.tres"),
	]
	
	return game_rules
