class_name ActionArmySplit
extends Action
## Splits a given [Army] into two or more armies with given troop size
## proportions. You must provide a new unique id for each of the new armies.

const ARMY_ID_KEY: String = "army_id"
const TROOP_PARTITION_KEY: String = "troop_partition"
const NEW_ARMY_IDS_KEY: String = "new_army_ids"

## The [Army] to split up.
## This army will be one of the resulting armies: it will not be deleted.
var _army_id: int

## This array contains the number of troops in each army.
## So for example, [47, 53] would split an army of 100 troops
## into one army of 47 and one army of 53.
## The sum of all the values in this array must add up
## to exactly the given army's size.
var _troop_partition: Array[int]

## This array's size should always be one less than the troop partition's size.
## For example, if the troop partition is [7, 8, 9], then the original army
## will be one of the resulting armies, so we need 2 new armies and 2 new ids.
var _new_army_ids: Array[int]


func _init(
		army_id: int,
		troop_partition: Array[int],
		new_army_ids: Array[int]
) -> void:
	_army_id = army_id
	_troop_partition = troop_partition
	_new_army_ids = new_army_ids


func apply_to(game: Game, player: GamePlayer) -> void:
	if _new_army_ids.size() < _troop_partition.size() - 1:
		push_error("Did not provide enough new army IDs for splitting army.")
		return

	var army: Army = game.world.armies.army_from_id(_army_id)
	if not army:
		push_warning("Tried to split an army that doesn't exist!")
		return

	if army.owner_country != player.playing_country:
		push_warning(
				"Tried to split an army, "
				+ "but the army is not under the player's control!"
		)
		return

	var partition_sum: int = 0
	for army_size in _troop_partition:
		if army_size < army.army_size.minimum():
			push_warning(
					"Tried to split an army, but at least one "
					+ "of the resulting armies was too small!"
			)
			return
		partition_sum += army_size

	if partition_sum != army.army_size.current_size():
		push_warning(
				"Tried to split an army, but the given partition's sum "
				+ "does not match the army's size! It should be "
				+ str(army.army_size.current_size()) + " but instead it is "
				+ str(partition_sum) + "."
		)
		return

	var number_of_clones: int = _troop_partition.size() - 1
	for i in number_of_clones:
		# Create the new army
		var _army_clone: Army = Army.quick_setup(
				game,
				_troop_partition[i + 1],
				army.owner_country,
				army.province_id(),
				_new_army_ids[i]
		)

		# Reduce the original army's troop count
		army.army_size.remove(_troop_partition[i + 1])


func raw_data() -> Dictionary:
	return {
		ID_KEY: ARMY_SPLIT,
		ARMY_ID_KEY: _army_id,
		TROOP_PARTITION_KEY: _troop_partition,
		NEW_ARMY_IDS_KEY: _new_army_ids,
	}


static func from_raw_data(data: Dictionary) -> ActionArmySplit:
	if not (
			ParseUtils.dictionary_has_number(data, ARMY_ID_KEY)
			and ParseUtils.dictionary_has_array(data, TROOP_PARTITION_KEY)
			and ParseUtils.dictionary_has_array(data, NEW_ARMY_IDS_KEY)
	):
		return null

	var troop_partition: Array[int] = (
			ParseUtils.dictionary_array_int(data, TROOP_PARTITION_KEY)
	)
	var new_army_ids: Array[int] = (
			ParseUtils.dictionary_array_int(data, NEW_ARMY_IDS_KEY)
	)

	if new_army_ids.size() < troop_partition.size() - 1:
		return null

	return ActionArmySplit.new(
			ParseUtils.dictionary_int(data, ARMY_ID_KEY),
			troop_partition,
			new_army_ids
	)
