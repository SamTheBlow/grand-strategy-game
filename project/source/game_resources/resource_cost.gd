class_name ResourceCost
## Class responsible for calculating how much of given game resource
## is required for given amount of something.
## For example, it could calculate the money cost to recruit 69 armies.

var _cost_for_one: float


func _init(cost_for_one: float) -> void:
	_cost_for_one = cost_for_one


func cost_fori(amount: int) -> int:
	return ceili(_cost_for_one * amount)


func cost_forf(amount: float) -> float:
	return _cost_for_one * amount
