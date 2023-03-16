extends Node

@export var fortresses:bool = false

func _ready():
	if fortresses:
		add_child(RuleFortress.new())
	
	var rules = get_children()
	for rule in rules:
		var _connect_error = rule.connect("game_over", Callable(get_parent(), "_on_game_over"))
		for signal_to_connect in rule.listen_to:
			_connect_error = get_node(signal_to_connect[0]).connect(signal_to_connect[1], Callable(rule, signal_to_connect[2]))

func start_of_turn(provinces:Array[Province], current_turn:int):
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
		var _connect_error = action.connect("action_played", Callable(rule, "_on_action_played"))
