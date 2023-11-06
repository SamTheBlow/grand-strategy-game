class_name GameTurn


var _turn: int


func _init(starting_turn: int = 1) -> void:
	_turn = starting_turn


func new_turn() -> void:
	_turn += 1


func as_JSON() -> int:
	return _turn
