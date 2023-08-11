class_name ActionArmySplit
extends Action


var _province_key: String
var _army_key: String

# This array contains the number of troops in each army.
# So for example, [47, 53] would split an army of 100 troops
# into one army of 47 and one army of 53.
var _troop_partition: Array[int]

var _new_army_keys: Array[String]


func _init(
	province_key: String,
	army_key: String,
	troop_partition: Array[int],
	new_army_keys: Array[String],
):
	_province_key = province_key
	_army_key = army_key
	_troop_partition = troop_partition
	_new_army_keys = new_army_keys


func apply_to(game_state: GameState) -> void:
	var armies: GameStateArray = game_state.armies(_province_key)
	var army_source: GameStateArray = game_state.army(_province_key, _army_key)
	
	# Create the new armies
	var number_of_clones: int = _troop_partition.size() - 1
	for i in number_of_clones:
		var unique_key: String = _new_army_keys[i]
		var army_clone := army_source.clone(unique_key) as GameStateArray
		army_clone.get_int("troop_count").data = _troop_partition[i + 1]
		armies.data().append(army_clone)
	
	# Reduce the original army's troop count
	game_state.army_troop_count(
		_province_key, _army_key
	).data = _troop_partition[0]
	
	#print("Army ", _army_key, " in province ", _province_key, " was split into ", _new_army_keys)
	super(game_state)


func update_visuals(provinces: Provinces) -> Array[Army]:
	var province_node: Province = provinces.province_with_key(_province_key)
	var armies_node: Armies = province_node.get_node("Armies") as Armies
	var army_node: Army = armies_node.army_with_key(_army_key)
	
	var number_of_clones: int = _troop_partition.size() - 1
	for i in number_of_clones:
		# We clone the existing army instead of instancing a new one
		# because then we would need to have the Army scene.
		# Remember, an Army has children like a Sprite2D, UI, etc.
		var army_node_clone := army_node.duplicate(7) as Army
		army_node_clone.owner_country = army_node.owner_country
		army_node_clone.troop_count = _troop_partition[i + 1]
		army_node_clone._key = _new_army_keys[i]
		armies_node.add_army(army_node_clone)
	
	# Reduce the original army's troop count
	army_node.set_troop_count(_troop_partition[0])
	
	return []
