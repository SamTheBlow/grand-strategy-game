class_name ArmyReinforcements
## Adds troops in each province according to the [GameRules]
## at the start of each turn. Creates a new [Army] if needed.

## Effect does not trigger while disabled.
var is_enabled: bool = false:
	set(value):
		if value == is_enabled:
			return
		is_enabled = value
		if is_enabled:
			_game.turn.turn_changed.connect(_on_turn_changed)
		else:
			_game.turn.turn_changed.disconnect(_on_turn_changed)

var _game: Game


func _init(game: Game) -> void:
	_game = game
	is_enabled = true


func _reinforce_provinces() -> void:
	for province in _game.world.provinces.list():
		_reinforce_province(province)


func _reinforce_province(province: Province) -> void:
	if (
			province.owner_country == null
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
					province.population.population_size
					* _game.rules.reinforcements_per_person.value
			)
		_:
			push_warning("Unrecognized army reinforcements option.")

	if reinforcements_size < _game.rules.minimum_army_size.value:
		return

	# Creating new armies is bad for performance.
	# It's better to directly increase an existing army's size.
	for army: Army in (
			_game.world.armies_in_each_province.in_province(province).list
	):
		if army.owner_country != province.owner_country:
			continue

		army.army_size.add(reinforcements_size)
		return

	# Couldn't find a valid army to reinforce. Create a new army.
	Army.quick_setup(
			_game,
			reinforcements_size,
			province.owner_country,
			province,
			-1,
			1
	)


func _on_turn_changed(_turn: int) -> void:
	_reinforce_provinces()
