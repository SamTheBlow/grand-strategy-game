class_name CountryPlacementGeneration
## Using given JSON data, tries to give each of the game's countries
## control over one province on the world map.


func apply(raw_data: Variant) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict := raw_data as Dictionary
	
	if not ParseUtils.dictionary_has_array(
			raw_dict, GameFromRawDict.COUNTRIES_KEY
	):
		raw_dict[GameFromRawDict.COUNTRIES_KEY] = []
	var countries_data: Array = raw_dict[GameFromRawDict.COUNTRIES_KEY]
	
	if not ParseUtils.dictionary_has_dictionary(
			raw_dict, GameFromRawDict.WORLD_KEY
	):
		push_error("Country placement failed: there is no world.")
		return
	var world_dict: Dictionary = raw_dict[GameFromRawDict.WORLD_KEY]
	
	if not ParseUtils.dictionary_has_array(
			world_dict, GameFromRawDict.WORLD_PROVINCES_KEY
	):
		push_error("Country placement failed: world doesn't have provinces.")
		return
	var provinces_array: Array = world_dict[GameFromRawDict.WORLD_PROVINCES_KEY]
	
	# Keep track of unassigned provinces.
	var unassigned_provinces: Array = provinces_array.duplicate()
	
	# If any country was already assigned to a province, unassign them.
	# Also remove invalid province data from the list.
	for province_data: Variant in unassigned_provinces.duplicate():
		if province_data is not Dictionary:
			unassigned_provinces.erase(province_data)
			continue
		
		var province_dict := province_data as Dictionary
		province_dict.erase(GameFromRawDict.PROVINCE_OWNER_ID_KEY)
	
	# Go through all the countries and assign
	# each of them to an unassigned province.
	for country_data: Variant in countries_data:
		if unassigned_provinces.size() == 0:
			break
		
		if country_data is not Dictionary:
			continue
		var country_dict := country_data as Dictionary
		
		if not ParseUtils.dictionary_has_number(
				country_dict, GameFromRawDict.COUNTRY_ID_KEY
		):
			continue
		var country_id: int = ParseUtils.dictionary_int(
				country_dict, GameFromRawDict.COUNTRY_ID_KEY
		)
		
		var random_index: int = randi() % unassigned_provinces.size()
		var random_province_dict: Dictionary = unassigned_provinces[random_index]
		random_province_dict[GameFromRawDict.PROVINCE_OWNER_ID_KEY] = country_id
		unassigned_provinces.remove_at(random_index)
