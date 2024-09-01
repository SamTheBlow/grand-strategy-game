class_name ProvinceControlGoal
## Responsible for telling when a [Country] meets the [Game]'s
## game over condition for number of [Province]s controlled.
## Emits a signal when the condition is met.


signal game_over()

var game: Game


## Checks if someone won from controlling a certain percentage
## of [Province]s and, if so, declares the game over.
##
## percentage_to_win should be a value from 0.0 to 1.0.
func _check_percentage_winner(percentage_to_win: float) -> void:
	var ownership: Array = game.world.provinces.province_count_per_country()
	var number_of_provinces: int = game.world.provinces.list().size()
	for o: Array in ownership:
		if float(o[1]) / number_of_provinces >= percentage_to_win:
			game_over.emit()
			break


## Checks if someone won from controlling a certain number
## of [Province]s and, if so, declares the game over.
func _check_number_winner(number_to_win: int) -> void:
	var ownership: Array = game.world.provinces.province_count_per_country()
	for o: Array in ownership:
		if o[1] >= number_to_win:
			game_over.emit()
			break


func _on_new_turn(_turn: int) -> void:
	# TODO bad code: hard coded values
	match game.rules.game_over_provinces_owned_option.selected:
		1:
			_check_number_winner(
					game.rules.game_over_provinces_owned_constant.value
			)
		2:
			_check_percentage_winner(
					game.rules.game_over_provinces_owned_percentage.value
			)
