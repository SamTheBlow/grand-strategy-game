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


func apply_to(game_state: GameState) -> void:
	var armies: Armies = (
			game_state.world.provinces.province_from_id(_province_id).armies
	)
	var army: Army = armies.army_from_id(_army_id)
	
	var number_of_clones: int = _troop_partition.size() - 1
	for i in number_of_clones:
		# Create the new army
		
		# We clone the existing army instead of instancing a new one
		# because then we would need to have the Army scene.
		# Remember, an Army has children like a Sprite2D, UI, etc.
		var army_clone := army.duplicate(7) as Army
		army_clone.id = _new_army_ids[i]
		army_clone.set_owner_country(army.owner_country())
		army_clone.setup(_troop_partition[i + 1])
		armies.add_army(army_clone)
		
		# Reduce the original army's troop count
		army.army_size.remove(_troop_partition[i + 1])
	
	#print(
	#		"Army ", _army_key, " in province ", _province_key,
	#		" was split into ", _new_army_keys
	#)
	super(game_state)
