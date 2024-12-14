class_name ArmiesInProvince
## Stores a list of armies.
## Automatically removes an [Army] from the list when it changes province.
##
## This doesn't automatically add armies when they enter the province, and it
## doesn't automatically remove armies when they are removed from the game.
## It's for performance reasons. Those things are handled by a separate class.
## See [ArmiesInProvinceSystem].

# TODO figure out how to expose the list without creating a new copy
# and while also preventing array manipulation from the outside.
# Creating copies of very large arrays is slow.
# And if we don't create a copy, then outsiders can add or remove items
# with no way for us to know about it.
## IMPORTANT: Do not directly add or remove items from this array!
## It will screw up everything.
var list: Array[Army] = []


## Adds given army to the list.
## Please use this, do not manipulate the array directly.
func add(army: Army) -> void:
	list.append(army)
	army.province_changed.connect(_on_army_province_changed)


## Removes given army from the list.
## Please use this, do not manipulate the array directly.
func remove(army: Army) -> void:
	list.erase(army)
	army.province_changed.disconnect(_on_army_province_changed)


## Removes the army from the list. (The army moved out of the province.)
func _on_army_province_changed(army: Army) -> void:
	remove(army)
