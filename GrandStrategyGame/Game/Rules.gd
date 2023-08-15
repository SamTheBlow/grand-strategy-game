class_name Rules
extends Node


@export var fortresses: bool = false


func _ready() -> void:
	if fortresses:
		add_child(RuleFortress.new())
	
	var rules: Array[Node] = get_children()
	for rule in rules:
		var _connect_error: int = rule.connect(
				"game_over", Callable(get_parent(), "_on_game_over")
		)
		for signal_to_connect in (rule as Rule).listen_to:
			_connect_error = get_node(signal_to_connect[0]).connect(
					signal_to_connect[1],
					Callable(rule, signal_to_connect[2])
			)


func start_of_turn(game_state: GameState) -> void:
	var rules: Array[Node] = get_children()
	for rule in rules:
		(rule as Rule)._on_start_of_turn(game_state)


func action_is_legal(game_state: GameState, action: Action) -> bool:
	if action is ActionArmySplit:
		var action_split := action as ActionArmySplit
		if game_state.provinces().index_of(action_split._province_key) == -1:
			push_warning(
					"Someone attempted to split an army
					in a province that doesn't exist"
			)
			return false
		if game_state.armies(action_split._province_key).index_of(action_split._army_key) == -1:
			push_warning(
					"Someone attempted to split an army that doesn't exist"
			)
			return false
	elif action is ActionArmyMovement:
		var action_movement := action as ActionArmyMovement
		if game_state.provinces().index_of(action_movement._province_key) == -1:
			push_warning(
					"Someone attempted to move an army
					from a province that doesn't exist"
			)
			return false
		if game_state.armies(action_movement._province_key).index_of(action_movement._army_key) == -1:
			push_warning(
					"Someone attempted to move an army that doesn't exist"
			)
			return false
		if game_state.provinces().index_of(action_movement._destination_key) == -1:
			push_warning(
					"Someone attempted to move an army
					to a province that doesn't exist"
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
