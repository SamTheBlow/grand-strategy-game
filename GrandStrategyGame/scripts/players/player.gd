class_name Player
## Class responsible for an individual player.
## This can be a human player or an AI.


var id: int

var playing_country: Country

var is_human: bool = false
var _ai_type: int

var _actions: Array[Action] = []


func _init(ai_type: int) -> void:
	_ai_type = ai_type


## Only works for human players.
## The AI will overwrite any action added with this command.
func add_action(action: Action) -> void:
	_actions.append(action)


func play_actions(game: Game) -> void:
	if is_human:
		_actions = []
		return
	else:
		_actions = _ai().actions(game, self)
	
	for action in _actions:
		action.apply_to(game, self)
	
	_actions.clear()


func _ai() -> PlayerAI:
	match _ai_type:
		0:
			return TestAI1.new()
		1:
			return TestAI2.new()
		_:
			print_debug("Player does not have a valid AI type.")
			return null
