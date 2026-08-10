class_name BuildingData
## Provides information about a building.

signal name_changed(new_value: String)
signal texture_changed(new_value: ProjectTexture)
signal defense_multiplier_changed(new_value: float)
signal can_be_built_changed(new_value: bool)
signal population_cost_changed(new_value: int)
signal money_cost_changed(new_value: int)

var building_name: String = "":
	set(value):
		if building_name == value:
			return
		building_name = value
		name_changed.emit(building_name)

var texture: ProjectTexture = ProjectTexture.none():
	set(value):
		if texture == value:
			return
		texture = value
		texture_changed.emit(texture)

var defense_multiplier: float = 1.0:
	set(value):
		if defense_multiplier == value:
			return
		defense_multiplier = value
		defense_multiplier_changed.emit(defense_multiplier)

var can_be_built: bool = true:
	set(value):
		if can_be_built == value:
			return
		can_be_built = value
		can_be_built_changed.emit(can_be_built)

var population_cost: int = 0:
	set(value):
		if population_cost == value:
			return
		population_cost = value
		population_cost_changed.emit(population_cost)

var money_cost: int = 0:
	set(value):
		if money_cost == value:
			return
		money_cost = value
		money_cost_changed.emit(money_cost)
