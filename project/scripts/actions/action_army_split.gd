class_name ActionArmySplit
extends Action
## Splits a given [Army] into two or more armies with given troop size
## proportions. You must provide a new unique id for each of the new armies.


var _army_id: int

# This array contains the number of troops in each army.
# So for example, [47, 53] would split an army of 100 troops
# into one army of 47 and one army of 53.
# NOTE: The original army will always be one of the resulting armies!
# That means the number of new Army objects will always be
# one less than the number of elements in this array.
var _troop_partition: Array[int]

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
	print("Splitting army ", _army_id, " into...")
	print(_new_army_ids)
	var army: Army = game.world.armies.army_with_id(_army_id)
	print("In province: ", army.province().id)
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
				_new_army_ids[i],
				_troop_partition[i + 1],
				army.owner_country,
				army.province()
		)
		
		# Reduce the original army's troop count
		army.army_size.remove(_troop_partition[i + 1])
	
	#print(
	#		"Army ", army.id, " in province ", army.province().id,
	#		" was split into ", _new_army_ids
	#)


## Returns this action's raw data, for the purpose of
## transfering between network clients.
func raw_data() -> Dictionary:
	return {
		"id": ARMY_SPLIT,
		"army_id": _army_id,
		"troop_partition": _troop_partition,
		"new_army_ids": _new_army_ids,
	}


# TODO verify that the data is valid
## Returns an action built with given raw data.
static func from_raw_data(data: Dictionary) -> ActionArmySplit:
	var troop_partition: Array[int] = []
	for part in data["troop_partition"] as Array[int]:
		troop_partition.append(part)
	
	var new_army_ids: Array[int] = []
	for id in data["new_army_ids"] as Array[int]:
		new_army_ids.append(id)
	
	return ActionArmySplit.new(
			data["army_id"] as int,
			troop_partition,
			new_army_ids
	)
