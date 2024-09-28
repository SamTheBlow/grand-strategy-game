class_name ProvinceControlGoal
## Emits the game_over signal when any [Country] meets the [Game]'s
## game over condition for number of [Province]s controlled.


signal game_over()

var _game: Game


func _init(game: Game) -> void:
	_game = game
	_game.turn.turn_changed.connect(_on_new_turn)


## Checks if someone won from controlling a certain percentage
## of [Province]s and, if so, declares the game over.
##
## percentage_to_win should be a value from 0.0 to 1.0.
func _check_percentage_winner(percentage_to_win: float) -> void:
	var provinces_list: Array[Province] = _game.world.provinces.list()
	var number_of_provinces: int = provinces_list.size()
	
	var pcpc := ProvinceCountPerCountry.new()
	pcpc.calculate(provinces_list)
	
	for i in pcpc.countries.size():
		if (
				float(pcpc.number_of_provinces[i]) / number_of_provinces
				>= percentage_to_win
		):
			game_over.emit()
			break


## Checks if someone won from controlling a certain number
## of [Province]s and, if so, declares the game over.
func _check_number_winner(number_to_win: int) -> void:
	var pcpc := ProvinceCountPerCountry.new()
	pcpc.calculate(_game.world.provinces.list())
	
	for i in pcpc.countries.size():
		if pcpc.number_of_provinces[i] >= number_to_win:
			game_over.emit()
			break


func _on_new_turn(_turn: int) -> void:
	match _game.rules.game_over_provinces_owned_option.selected_value():
		GameRules.GameOverProvincesOwnedOption.CONSTANT:
			_check_number_winner(
					_game.rules.game_over_provinces_owned_constant.value
			)
		GameRules.GameOverProvincesOwnedOption.PERCENTAGE:
			_check_percentage_winner(
					_game.rules.game_over_provinces_owned_percentage.value
			)
