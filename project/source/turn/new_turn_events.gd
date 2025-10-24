class_name NewTurnEvents
## On each new turn, iterates through all of given [Provinces]
## and applies given events.

var _game: Game

func _init(game: Game) -> void:
	_game = game
	_game.turn.turn_changed.connect(_on_turn_changed)


func _on_turn_changed(_turn: int) -> void:
	for province in _game.world.provinces.list():
		ArmyReinforcements.apply(_game, province)
		PopulationGrowth.apply(_game, province)
		IncomeEachTurn.apply(_game.rules, province)
