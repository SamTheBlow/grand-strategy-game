extends "res://Game/Actions/Action.gd"
class_name ActionArmySplit

var army:Army

# This array contains the number of troops in each army.
# So for example, [47, 53] would split an army of 100 troops
# into one army of 47 and one army of 53.
var troop_partition:PoolIntArray

func _init(army_:Army = null, troop_partition_:PoolIntArray = []):
	army = army_
	troop_partition = troop_partition_
	
	# Remove armies with 0 troops
	# TODO this shouldn't happen in the first place.
	var zero = troop_partition.find(0)
	while zero != -1:
		troop_partition.remove(zero)
		zero = troop_partition.find(0)
	
	# Delete yourself if there isn't actually any splitting to do
	# TODO this shouldn't happen. Throw an error instead
	if troop_partition.size() <= 1:
		queue_free()

func play_action():
	var number_of_clones = troop_partition.size() - 1
	for i in number_of_clones:
		var army_clone = army.duplicate(7)
		army_clone.owner_country = army.owner_country
		army_clone.troop_count = troop_partition[i + 1]
		army_clone.is_active = true
		army.get_parent().get_parent().add_troops(army_clone)
	army.troop_count = troop_partition[0]
	army.is_active = true
	.play_action()
