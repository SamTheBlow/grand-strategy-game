class_name ActionArmySplit
extends Action


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


func apply_to(game: Game, player: Player) -> void:
	var army: Army = game.world.armies.army_with_id(_army_id)
	if not army:
		push_warning("Tried to split an army that doesn't exist!")
		return
	
	if army.owner_country() != player.playing_country:
		push_warning(
				"Tried to split an army, "
				+ "but the army is not under the player's control!"
		)
		return
	
	# TODO don't hard code minimum army size
	var partition_sum: int = 0
	for army_size in _troop_partition:
		if army_size < 10:
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
				army.owner_country(),
				army.province()
		)
		
		# Reduce the original army's troop count
		army.army_size.remove(_troop_partition[i + 1])
	
	#print(
	#		"Army ", army.id, " in province ", army.province().id,
	#		" was split into ", _new_army_ids
	#)
