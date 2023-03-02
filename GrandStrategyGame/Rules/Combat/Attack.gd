extends Node
class_name Attack

var attacker:Army
var defender:Army
var province:Province
var attacker_efficiency:float = 1

func _init(attacker_:Army, defender_:Army, province_:Province):
	attacker = attacker_
	defender = defender_
	province = province_
