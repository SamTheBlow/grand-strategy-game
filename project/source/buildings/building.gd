class_name Building

var data := BuildingData.new()

var _province_id: int = -1


func _init(initial_data: BuildingData, province_id: int) -> void:
	data = initial_data
	_province_id = province_id


## Applies the defense multiplier when a battle occurs.
func _on_modifiers_requested(
		modifiers: Array[Modifier], context: ModifierContext
) -> void:
	match context.context():
		"attacker_efficiency":
			# Check if defender is on same province as this building
			var defender: Army = context.info("defending_army")
			if _province_id == defender.province_id():
				# New modifier
				modifiers.append(ModifierMultiplier.new(
						data.building_name,
						"The building's defense multiplier (inversed).",
						1.0 / data.defense_multiplier
						if data.defense_multiplier != 0.0 else 1.0
				))
		"defender_efficiency":
			# Check if defender is on same province as this building
			var defender: Army = context.info("defending_army")
			if _province_id == defender.province_id():
				# New modifier
				modifiers.append(ModifierMultiplier.new(
						data.building_name,
						"The building's defense multiplier.",
						1.0 * data.defense_multiplier
				))
