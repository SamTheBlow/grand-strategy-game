class_name CountryOwnershipGiver
extends Node
## Gives/removes control of some province to some selected country.

## The country to give control of provinces to.
## This node has no effect if this is null.
var _selected_country: Country = null

var _undo_redo := UndoRedo.new()


func _on_history_initialized(undo_redo: UndoRedo) -> void:
	_undo_redo = undo_redo


## Sets it to no country if input is empty or null.
func set_selected_country(country: Country = null) -> void:
	_selected_country = country


func apply_to_province(province: Province) -> void:
	if _selected_country == null:
		return

	var country_before: Country = province.owner_country
	var country_after: Country = (
			null if country_before == _selected_country else _selected_country
	)

	_undo_redo.create_action("Change province owner")
	_undo_redo.add_do_property(province, &"owner_country", country_after)
	_undo_redo.add_undo_property(province, &"owner_country", country_before)
	_undo_redo.commit_action()
