class_name ArmiesInProvince
## Keeps track of all armies located in given [Province].


var _province: Province

# TODO figure out how to expose the list without having to create a new copy.
# This is important because creating copies of very large arrays is slow.
# And not creating a new copy is also bad because
# then outsiders can add or remove items.
## IMPORTANT: Do not add or remove items from this array!
## It will screw up everything.
var list: Array[Army] = []


func _init(armies: Armies, province: Province) -> void:
	_province = province

	for army in armies.list():
		_on_army_added(army)

	armies.army_added.connect(_on_army_added)
	armies.army_removed.connect(_on_army_removed)


func _on_army_added(army: Army) -> void:
	if army.province() == _province:
		list.append(army)
	army.province_changed.connect(_on_army_province_changed)


func _on_army_removed(army: Army) -> void:
	army.province_changed.disconnect(_on_army_province_changed)
	if army in list:
		list.erase(army)


func _on_army_province_changed(army: Army) -> void:
	if army.province() == _province:
		# The army changed province and is now in the target province.
		# That means it wasn't there before. Add it to the list.
		list.append(army)
	elif army in list:
		# The army was in the list, and it changed province.
		# That means it moved out of the province. Remove it from the list.
		list.erase(army)
