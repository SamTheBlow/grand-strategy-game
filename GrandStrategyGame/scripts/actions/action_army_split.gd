class_name ActionArmySplit
extends Action


var _province_id: int
var _army_id: int

# This array contains the number of troops in each army.
# So for example, [47, 53] would split an army of 100 troops
# into one army of 47 and one army of 53.
var _troop_partition: Array[int]

var _new_army_ids: Array[int]


func _init(
		province_id: int,
		army_id: int,
		troop_partition: Array[int],
		new_army_ids: Array[int]
) -> void:
	_province_id = province_id
	_army_id = army_id
	_troop_partition = troop_partition
	_new_army_ids = new_army_ids


func apply_to(game_state: GameState, _is_simulation: bool) -> void:
	var province: Province = (
			game_state.world.provinces.province_from_id(_province_id)
	)
	if not province:
		push_warning(
				"Tried to split an army in a province that doesn't exist"
		)
		return
	
	var army: Army = province.armies.army_from_id(_army_id)
	if not army:
		push_warning("Tried to split an army that doesn't exist")
		return
	
	# TODO bad code, shouldn't be in this class
	for army_size in _troop_partition:
		if army_size < 10:
			push_warning(
					"Tried to split an army, but at least one"
					+ " of the resulting armies was too small!"
			)
			return
	
	var number_of_clones: int = _troop_partition.size() - 1
	for i in number_of_clones:
		# Create the new army
		var army_clone: Army = Army.quick_setup(
				game_state.game,
				_new_army_ids[i],
				_troop_partition[i + 1],
				army.owner_country(),
				preload("res://scenes/army.tscn")
		)
		army_clone._province = province
		province.armies.add_army(army_clone)
		
		# Reduce the original army's troop count
		army.army_size.remove(_troop_partition[i + 1])
	
	#print(
	#		"Army ", _army_key, " in province ", _province_key,
	#		" was split into ", _new_army_keys
	#)
