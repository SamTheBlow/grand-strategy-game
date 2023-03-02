# In the future, methods should be added to build/destroy the fortress
extends ProvinceComponent
class_name Fortress

var is_built:bool = false : set = set_is_built

func init(is_built_:bool, position_:Vector2):
	is_built = is_built_
	position = position_

func set_is_built(is_built_:bool):
	visible = is_built_
	is_built = is_built_

# Double the defender's defense during an attack
func _on_attack(attack:Attack):
	if is_built:
		attack.attacker_efficiency *= 0.5
