class_name Population
extends ProvinceComponent
# Note: population behaviors such as growth,
# recruitment, etc. should be defined as Rule nodes.


var population_count: int = 0


func _init(population_count_: int):
	population_count = population_count_
