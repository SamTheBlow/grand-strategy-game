class_name Rules
extends Node


signal game_over(Country)

@export var fortresses: bool = false


func setup() -> void:
	if fortresses:
		pass
	
	var rules: Array[Node] = get_children()
	for rule in rules:
		rule.connect("game_over", Callable(self, "_on_game_over"))
		for signal_to_connect in (rule as Rule).listen_to:
			get_node(signal_to_connect[0]).connect(
					signal_to_connect[1],
					Callable(rule, signal_to_connect[2])
			)


func _on_game_over(winner: Country) -> void:
	game_over.emit(winner)


func start_of_turn(game_state: GameState) -> void:
	var rules: Array[Node] = get_children()
	for rule in rules:
		(rule as Rule)._on_start_of_turn(game_state)


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


func connect_action(action: Action) -> void:
	var rules: Array[Node] = get_children()
	for rule in rules:
		var _connect_error = action.connect(
				"action_applied",
				Callable(rule, "_on_action_applied")
		)


static func build() -> Rules:
	var game_rules := Rules.new()
	game_rules.name = "Rules"
	game_rules.add_child(RuleNewProvinceOwnership.new())
	game_rules.add_child(RuleProvincePercentageToWin.new())
	game_rules.add_child(RuleMinArmySize.new())
	var rule_combat := RuleCombat.new()
	rule_combat.name = "Combat"
	game_rules.add_child(rule_combat)
	game_rules.add_child(RulePopGrowth.new())
	game_rules.add_child(RuleAutoRecruit.new())
	return game_rules


func as_JSON() -> Dictionary:
	return {
		"fortress": fortresses,
	}
