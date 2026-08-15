class_name ArmyData
## Holds army data.

## This value will never be less than 1.
var minimum_size: int = 1:
	set(value):
		minimum_size = maxi(1, value)

## If this is less than 1, then it means there is no maximum size.
var maximum_size: int = -1:
	set(value):
		maximum_size = value if value >= 1 else -1
