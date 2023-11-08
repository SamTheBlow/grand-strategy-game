class_name Rules
extends Node


@export var fortresses: bool = false


func action_is_legal(game_state: GameState, action: Action) -> bool:
	if action is ActionArmySplit:
		var action_split := action as ActionArmySplit
		var province: Province = (
				game_state.world.provinces
				.province_from_id(action_split._province_id)
		)
		if not province:
			push_warning(
					"Tried to split an army in a province that doesn't exist"
			)
			return false
		if not province.armies.army_from_id(action_split._army_id):
			push_warning("Tried to split an army that doesn't exist")
			return false
	elif action is ActionArmyMovement:
		var action_movement := action as ActionArmyMovement
		var province: Province = (
				game_state.world.provinces
				.province_from_id(action_movement._province_id)
		)
		if not province:
			push_warning(
					"Tried to move an army from a province that doesn't exist"
			)
			return false
		if not province.armies.army_from_id(action_movement._army_id):
			push_warning("Tried to move an army that doesn't exist")
			return false
		var destination_province: Province = (
				game_state.world.provinces
				.province_from_id(action_movement._destination_province_id)
		)
		if not destination_province:
			push_warning(
					"Tried to move an army to a province that doesn't exist"
			)
			return false
	
	var rules: Array[Node] = get_children()
	for rule in rules:
		if not (rule as Rule).action_is_legal(game_state, action):
			return false
	
	return true


static func build() -> Rules:
	var game_rules := Rules.new()
	game_rules.name = "Rules"
	game_rules.add_child(RuleMinArmySize.new())
	return game_rules


func as_JSON() -> Dictionary:
	return {
		"fortress": fortresses,
	}
