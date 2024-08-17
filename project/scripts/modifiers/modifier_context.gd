class_name ModifierContext
extends Resource
## In the context of the [ModifierRequest], this resource
## provides information on what kind of [Modifier] is being requested.
## Currently, there is only one such context: "defending_army"
## to be provided when a [Battle] occurs.
##
## This class is a bit ugly, so it might change or get removed in the future.
## @experimental


@export var _context: String

var _defending_army: Army


func context() -> String:
	return _context


# TODO bad code.
func info(info_string: String) -> Variant:
	match info_string:
		"defending_army":
			return _defending_army
		_:
			push_warning(
					"Received unrecognized info string "
					+ '"' + info_string + '".'
			)
			return null
