class_name GameRules


var population_growth: bool = true
var fortresses: bool = false
var turn_limit_enabled: bool = false
var turn_limit: int = 50


static func from_json(json_data: Dictionary) -> GameRules:
	var game_rules := GameRules.new()
	game_rules.population_growth = json_data["population_growth"]
	game_rules.fortresses = json_data["fortresses"]
	game_rules.turn_limit_enabled = json_data["turn_limit_enabled"]
	game_rules.turn_limit = json_data["turn_limit"]
	return game_rules


func as_json() -> Dictionary:
	return {
		"population_growth": population_growth,
		"fortresses": fortresses,
		"turn_limit_enabled": turn_limit_enabled,
		"turn_limit": turn_limit,
	}
