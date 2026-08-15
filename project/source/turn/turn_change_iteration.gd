class_name TurnChangeIteration

## At the start of each turn, emits this once for every province in the game.
signal turn_changed_province(province: Province)


func register(game: Game) -> void:
	game.turn.turn_changed.connect(_on_turn_changed.bind(game).unbind(1))


func _on_turn_changed(game: Game) -> void:
	for province in game.world.provinces.list():
		turn_changed_province.emit(province)
