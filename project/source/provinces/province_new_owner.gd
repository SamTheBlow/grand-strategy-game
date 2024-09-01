class_name ProvinceNewOwner
## Determines which [Country] controls a given [Province].
## Once it is determined, it is applied immediately.


func update_province_owner(province: Province) -> void:
	var current_owner: Country = province.owner_country
	var new_owner: Country = current_owner
	
	var armies: Array[Army] = (
			province.game.world.armies.armies_in_province(province)
	)
	for army in armies:
		# If this province's owner has an army here,
		# then it can't be taken by someone else.
		if army.owner_country == province.owner_country:
			return
		
		# Priority goes to the first army that landed here
		if new_owner != current_owner:
			continue
		
		# If this army's owner is not trespassing,
		# then it won't take control over the province.
		if not (
				army.owner_country.relationships
				.with_country(province.owner_country).is_trespassing()
		):
			continue
		
		new_owner = army.owner_country
	
	province.owner_country = new_owner
