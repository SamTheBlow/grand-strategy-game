class_name ArmiesInProvinceSystem
## Updates the [ArmiesInProvince] list of each province
## so that it correctly represents a list of all armies in the province.
# This is its own independent system for performance reasons.
# It's much faster to receive signals only once
# rather than receive them once for each province in the game.


func _init(armies: Armies) -> void:
	for army in armies.list():
		_on_army_added(army)

	armies.army_added.connect(_on_army_added)
	armies.army_removed.connect(_on_army_removed)


func _on_army_added(army: Army) -> void:
	_on_army_province_changed(army)
	army.province_changed.connect(_on_army_province_changed)


func _on_army_removed(army: Army) -> void:
	army.province_changed.disconnect(_on_army_province_changed)
	if army.province() != null:
		army.province().armies.remove(army)


## Adds the army to the new province's list.
## As for removing the army from the previous province's list,
## the previous province's list does this by itself.
func _on_army_province_changed(army: Army) -> void:
	if army.province() != null:
		army.province().armies.add(army)
