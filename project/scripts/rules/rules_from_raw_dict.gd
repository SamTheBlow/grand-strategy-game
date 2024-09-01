class_name RulesFromRawDict
## Converts raw data into a new [GameRules] resource.
##
## See also: [RulesToRawDict]


func result(data_dict: Dictionary) -> GameRules:
	var game_rules := GameRules.new()
	for key in GameRules.RULE_NAMES:
		# If the rule isn't there, that's ok, just use the default
		if not data_dict.has(key):
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
	
	# TODO temporary. remove later
	game_rules.diplomatic_presets = DiplomacyPresets.new([
		load("res://resources/diplomacy/presets/allied.tres"),
		load("res://resources/diplomacy/presets/neutral.tres"),
		load("res://resources/diplomacy/presets/at_war.tres"),
	])
	game_rules.diplomatic_actions = DiplomacyActionDefinitions.new([
		load("res://resources/diplomacy/actions/break_alliance.tres"),
		load("res://resources/diplomacy/actions/declare_war.tres"),
		load("res://resources/diplomacy/actions/offer_alliance.tres"),
		load("res://resources/diplomacy/actions/offer_peace.tres"),
		load("res://resources/diplomacy/actions/grant_military_access.tres"),
		load("res://resources/diplomacy/actions/revoke_military_access.tres"),
		load("res://resources/diplomacy/actions/ask_for_military_access.tres"),
		load("res://resources/diplomacy/actions/start_trespassing.tres"),
		load("res://resources/diplomacy/actions/stop_trespassing.tres"),
		load("res://resources/diplomacy/actions/ask_to_stop_trespassing.tres"),
		load("res://resources/diplomacy/actions/start_fighting.tres"),
		load("res://resources/diplomacy/actions/stop_fighting.tres"),
		load("res://resources/diplomacy/actions/ask_to_stop_fighting.tres"),
	])
	game_rules.battle = load("res://resources/battle.tres") as Battle
	
	return game_rules
