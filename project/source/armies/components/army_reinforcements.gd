class_name ArmyReinforcements
extends GameComponent
## Each turn, adds additional troops in each claimed province.

const KEY: String = "army_reinforcements"

const _CONSTANT_AMOUNT_KEY: String = "constant_amount"
const _RANDOM_SPREAD_KEY: String = "random_spread"
const _AMOUNT_PER_PERSON_KEY: String = "amount_per_person"

## Base amount of troops to reinforce with.
var constant_amount: int = 0

## Controls by how much the amount varies. Must be a value from 0 to 1.
## For reference, 0.0 gives no variance
## and 1.0 ranges from zero to double the amount.
var random_spread: float = 0.0

## The amount of troops to reinforce with per person in the province.
var amount_per_person: float = 0.0


func _init() -> void:
	priority_index = 10


func register(game: Game) -> void:
	game.turn.turn_changed.connect(_apply.bind(game).unbind(1))


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if constant_amount != 0:
		output[_CONSTANT_AMOUNT_KEY] = constant_amount
	if random_spread != 0.0:
		output[_RANDOM_SPREAD_KEY] = random_spread
	if amount_per_person != 0.0:
		output[_AMOUNT_PER_PERSON_KEY] = amount_per_person
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _CONSTANT_AMOUNT_KEY):
		constant_amount = ParseUtils.dictionary_int(
				raw_dict, _CONSTANT_AMOUNT_KEY
		)
	else:
		constant_amount = 0

	if ParseUtils.dictionary_has_number(raw_dict, _RANDOM_SPREAD_KEY):
		random_spread = ParseUtils.dictionary_float(
				raw_dict, _RANDOM_SPREAD_KEY
		)
	else:
		random_spread = 0.0

	if ParseUtils.dictionary_has_number(raw_dict, _AMOUNT_PER_PERSON_KEY):
		amount_per_person = ParseUtils.dictionary_float(
				raw_dict, _AMOUNT_PER_PERSON_KEY
		)
	else:
		amount_per_person = 0.0

	error = false
	error_message = ""


func _apply(game: Game) -> void:
	for province in game.world.provinces.list:
		if province.owner_country == null:
			continue

		var reinforcements_size := int(
				(
						constant_amount
						+ province.population().value * amount_per_person
				)
				* ((game.rng.randf() * 2.0 - 1.0) * random_spread + 1.0)
		)

		# Creating new armies is bad for performance.
		# It's better to directly increase an existing army's size.
		var is_existing_army_reinforced: bool = false
		for army: Army in (
				game.world.armies_in_each_province.dictionary[province.id]
				.ordered_list
		):
			if army.owner_country == province.owner_country:
				army.size().value += reinforcements_size
				is_existing_army_reinforced = true
				break

		# If we couldn't find an army to reinforce, create a new one.
		# Don't create a new army if it's too small.
		if (
				not is_existing_army_reinforced
				and reinforcements_size >= game.world.army_data.minimum_size
		):
			Army.Factory.new(game).new_army(
					province.owner_country,
					province.id,
					reinforcements_size,
					-1,
					1
			)
