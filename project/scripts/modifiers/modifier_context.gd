class_name ModifierContext
extends Resource


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
			print_debug('Modifier context: received invalid info string "%s"' % info_string)
			return null
