class_name ArmyWithPositions
## Bundle class that stores an [Army]
## along with its index in an [Armies] list
## and its index in an [ArmiesInProvince] list.

var army: Army
var armies_index: int
var province_index: int


func _init(army_: Army, armies_index_: int, province_index_: int) -> void:
	army = army_
	armies_index = armies_index_
	province_index = province_index_
