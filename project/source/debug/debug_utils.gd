class_name DebugUtils
## Utility functions for debugging.


## Prints the status of all country relationships.
static func print_relationships(countries: Countries) -> void:
	for country_1 in countries._list:
		print("Country: ", country_1.country_name)
		for country_2 in countries._list:
			if country_1 == country_2:
				continue
			print(
					"	", country_2.country_name, ": ",
					country_1.relationships
					.with_country(country_2).preset().name
			)
