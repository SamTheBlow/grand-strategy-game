class_name ArmiesOfCountry
## Contains a list of all armies controlled by some [Country].
## Removes armies from the list when they change allegiance.

## Do not manipulate this list directly! Use add() and remove() instead.
var list: Array[Army] = []


func add(army: Army) -> void:
	list.append(army)
	army.allegiance_changed.connect(_on_army_allegiance_changed)


func remove(army: Army) -> void:
	army.allegiance_changed.disconnect(_on_army_allegiance_changed)
	list.erase(army)


func _on_army_allegiance_changed(army: Army) -> void:
	remove(army)
