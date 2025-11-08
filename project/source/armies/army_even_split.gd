class_name ArmyEvenSplit
## Creates [ActionArmySplit]s and [ActionArmyMovement]s
## such that the given [Army] is evenly split and moved to
## all given destination [Province]s.

## If there are more targets than available troops,
## then no split will occur, and this property will stay null.
var action_army_split: ActionArmySplit

## This array will always be the same size as the number of given
## destination provinces, and they will be in the same order too.
## But, there is no guarantee that any of the actions are valid.
## For example, if you provide a province the army cannot reach,
## then an invalid action will be created anyway.
var action_army_movements: Array[ActionArmyMovement] = []

var _armies: Armies


func _init(armies: Armies) -> void:
	_armies = armies


func apply(army: Army, destination_provinces: Array[Province]) -> void:
	var number_of_targets: int = destination_provinces.size()
	if number_of_targets == 0:
		return
	var troop_count: int = army.size().value
	@warning_ignore("integer_division")
	var troops_per_army: int = troop_count / number_of_targets

	if troops_per_army < army.size().minimum_value:
		return

	var new_army_ids: Array[int] = []
	if number_of_targets > 1:
		new_army_ids = (
				_armies.id_system()
				.new_unique_ids(number_of_targets - 1, false)
		)

		# Create the partition
		var troop_partition: Array[int] = []
		for i in number_of_targets:
			troop_partition.append(troops_per_army)
		troop_partition[0] += troop_count % number_of_targets

		action_army_split = ActionArmySplit.new(
				army.id, troop_partition, new_army_ids
		)

	for i in number_of_targets:
		var army_id: int = army.id if i == 0 else new_army_ids[i - 1]
		action_army_movements.append(ActionArmyMovement.new(
				army_id, destination_provinces[i].id
		))
