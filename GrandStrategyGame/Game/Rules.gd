extends Node

func _ready():
	var rules = get_children()
	for rule in rules:
		var _connect_error = rule.connect("game_over", get_parent(), "_on_game_over")
		for signal_to_connect in rule.listen_to:
			_connect_error = get_node(signal_to_connect[0]).connect(signal_to_connect[1], rule, signal_to_connect[2])

func start_of_turn(provinces, current_turn):
	var rules = get_children()
	for rule in rules:
		rule._on_start_of_turn(provinces, current_turn)

func action_is_legal(action:Action) -> bool:
	var rules = get_children()
	for rule in rules:
		if rule.action_is_legal(action) == false:
			return false
	return true

func connect_action(action:Action):
	var rules = get_children()
	for rule in rules:
		var _connect_error = action.connect("action_played", rule, "_on_action_played")
