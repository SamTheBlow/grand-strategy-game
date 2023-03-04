extends "res://Game/Actions/Action.gd"
class_name ActionArmySplit

var army:Army

# We need the province that the army is in.
# This is because when we create the new armies,
# we need to know where to put them.
var province:Province

# This array contains the number of troops in each army.
# So for example, [47, 53] would split an army of 100 troops
# into one army of 47 and one army of 53.
var troop_partition:PackedInt32Array

func _init(army_:Army = null, province_:Province = null, troop_partition_:PackedInt32Array = []):
	army = army_
	province = province_
	troop_partition = troop_partition_

func play_action():
	var number_of_clones = troop_partition.size() - 1
	for i in number_of_clones:
		# We clone the existing army instead of instancing a new one
		# because then we would need to have the Army scene.
		# Remember, an Army has children like a Sprite2D, UI, etc.
		var army_clone = army.duplicate(7)
		army_clone.owner_country = army.owner_country
		army_clone.troop_count = troop_partition[i + 1]
		army_clone.is_active = true
		province.get_node("Armies").add_army(army_clone)
	army.troop_count = troop_partition[0]
	army.is_active = true
	super()
