class_name ProvinceNewOwner
## Determines which [Country] controls a given [Province].
## Once it is determined, it is applied immediately.


func update_province_owner(province: Province) -> void:
	var current_owner: Country = province.owner_country()
	var new_owner: Country = current_owner
	
	var armies: Array[Army] = province.game.world.armies.armies_in_province(province)
	for army in armies:
		# If this province's owner has an army here,
		# then it can't be taken by someone else
		if army.owner_country == province.owner_country():
			return
		new_owner = army.owner_country
	
	if new_owner == current_owner:
		return
	
	province.set_owner_country(new_owner)
