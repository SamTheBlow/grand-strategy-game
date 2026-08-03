class_name CountryOwnershipGiver
extends Node
## Gives/removes control of some province to some selected country.

## This node has no effect when disabled.
var is_enabled: bool = false

## The country to give control of provinces to.
## This node has no effect if this is null.
var selected_country: Country = null

var _undo_redo := UndoRedo.new()


func _on_history_initialized(undo_redo: UndoRedo) -> void:
	_undo_redo = undo_redo


func apply_to_province(province: Province) -> void:
	if not is_enabled or selected_country == null:
		return

	var country_before: Country = province.owner_country
	var country_after: Country = (
			null if country_before == selected_country else selected_country
	)

	_undo_redo.create_action("Change province owner")
	_undo_redo.add_do_property(province, &"owner_country", country_after)
	_undo_redo.add_undo_property(province, &"owner_country", country_before)
	_undo_redo.commit_action()
