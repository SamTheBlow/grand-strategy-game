class_name DebugUtils
## Utility functions for debugging.


## Prints the status of all country relationships.
static func print_relationships(countries: Countries) -> void:
	for country_1 in countries._list:
		print("Country: ", country_1.name_or_default())
		for country_2 in countries._list:
			if country_1 == country_2:
				continue
			print(
					"	", country_2.name_or_default(), ": ",
					country_1.relationships
					.with_country(country_2).preset().name
			)


## Print nicely formatted information about given [UndoRedo].
static func print_undo_redo(undo_redo: UndoRedo) -> void:
	print("[UNDO REDO] Current version: ", undo_redo.get_version())
	for i in undo_redo.get_history_count():
		print(i, ": ", undo_redo.get_action_name(i))
