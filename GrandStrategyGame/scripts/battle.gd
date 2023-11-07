class_name Battle


var _attacking_army: Army
var _defending_army: Army
var attacker_efficiency: float = 1.0


func _init(
		attacking_army: Army,
		defending_army: Army
) -> void:
	_attacking_army = attacking_army
	_defending_army = defending_army


func apply() -> void:
	var delta: int = (
			int(_attacking_army.army_size.current_size() * attacker_efficiency)
			- _defending_army.army_size.current_size()
	)
	#print(
	#		"Battle occured. Attacker ", _attacking_army.id,
	#		" ; Defender ", _defending_army.id,
	#		" ; Delta ", delta,
	#		" (", "battle was a tie" if delta == 0 else
	#		("attacker won" if delta > 0 else "defender won"), ")"
	#)
	if delta > 0:
		# TODO bad code
		_attacking_army.army_size.remove(
				_attacking_army.army_size.current_size() - delta
		)
		_defending_army.destroy()
	elif delta < 0:
		_attacking_army.destroy()
		_defending_army.army_size.remove(
				_defending_army.army_size.current_size() + delta
		)
	else:
		_attacking_army.destroy()
		_defending_army.destroy()
