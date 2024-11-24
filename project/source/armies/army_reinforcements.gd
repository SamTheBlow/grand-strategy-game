class_name ArmyReinforcements
## Class responsible for spawning a new [Army] in given
## [Province] according to the [GameRules] at the start of each turn.
## Merges the armies in given province after creating an army.


var _game: Game
var _province: Province


func _init(game: Game, province: Province) -> void:
	_game = game
	_province = province

	_game.turn.turn_changed.connect(_on_new_turn)


func _reinforce_province() -> void:
	if (
			_province == null
			or _province.owner_country == null
			or not _game.rules.reinforcements_enabled.value
	):
		return

	var reinforcements_size: int = 0
	match _game.rules.reinforcements_option.selected_value():
		GameRules.ReinforcementsOption.RANDOM:
			reinforcements_size = _game.rng.randi_range(
					_game.rules.reinforcements_random_min.value,
					_game.rules.reinforcements_random_max.value
			)
		GameRules.ReinforcementsOption.CONSTANT:
			reinforcements_size = (
					_game.rules.reinforcements_constant.value
			)
		GameRules.ReinforcementsOption.POPULATION:
			reinforcements_size = floori(
					_province.population.population_size
					* _game.rules.reinforcements_per_person.value
			)
		_:
			push_warning("Unrecognized army reinforcements option.")

	if reinforcements_size < _game.rules.minimum_army_size.value:
		return

	Army.quick_setup(
			_game,
			reinforcements_size,
			_province.owner_country,
			_province,
			-1,
			1
	)
	_game.world.armies.merge_armies(_province)


func _on_new_turn(_turn: int) -> void:
	_reinforce_province()
