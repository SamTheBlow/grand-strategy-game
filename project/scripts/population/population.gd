class_name Population


signal size_changed(new_value: int)

var _game: Game

## Must be positive or zero
var population_size: int = 0:
	set(value):
		var previous_value: int = population_size
		population_size = value
		if value != previous_value:
			size_changed.emit(value)


func _init(game: Game) -> void:
	_game = game
	_game.turn.turn_changed.connect(_on_new_turn)


func _on_new_turn(_turn: int) -> void:
	PopulationGrowth.new().apply(_game.rules, self)
