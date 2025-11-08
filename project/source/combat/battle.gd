class_name Battle
extends Resource
## This class defines the outcome of a battle between two opposing armies.
# TODO this class is ugly, needs lots of refactoring!

@export var _context_attacker_efficiency: ModifierContext
@export var _context_defender_efficiency: ModifierContext

var battle_algorithm_option: int = 0
var modifier_request: ModifierRequest

var _both_armies_survived: bool = true


func apply(attacking_army: Army, defending_army: Army) -> void:
	#print("A battle is about to begin!")
	#print("Algorithm: ", battle_algorithm_option)

	_context_attacker_efficiency._defending_army = defending_army
	_context_defender_efficiency._defending_army = defending_army

	var damage_dealt: Array[int] = []
	match battle_algorithm_option:
		0:
			damage_dealt = _algorithm_0(attacking_army, defending_army)
		1:
			damage_dealt = _algorithm_1(attacking_army, defending_army)
		_:
			push_error("Unrecognized battle algorithm id.")
			return
	var attacker_damage: int = damage_dealt[0]
	var defender_damage: int = damage_dealt[1]

	_both_armies_survived = true
	var army_death: Callable = func() -> void:
		_both_armies_survived = false
	attacking_army.size().became_too_small.connect(army_death)
	defending_army.size().became_too_small.connect(army_death)

	# The attacker attacks first
	#print("=====\nA battle occurs!")
	#print("Attacker %s (%s) has army size of %s" % [attacking_army.owner_country.name_or_default(), attacking_army.id, attacker_army_size])
	#print("Defender %s (%s) has army size of %s" % [defending_army.owner_country.name_or_default(), defending_army.id, defender_army_size])
	#print("Attacker deals %s damage! Attacker efficiency: %s" % [attacker_damage, attacker_efficiency])
	defending_army.size().value -= attacker_damage
	#print("Defender army size is down to %s" % defending_army.size().value)
	#print("Defender deals %s damage! Defender efficiency: %s" % [defender_damage, defender_efficiency])
	attacking_army.size().value -= defender_damage
	#print("Attacker army size is down to %s" % attacking_army.size().value)

	#print("Both armies survived? ", _both_armies_survived)

	# If both armies survived the battle, destroy the attacker
	# (ensures that at least one side is destroyed)
	if _both_armies_survived:
		attacking_army.destroy()


func _algorithm_0(attacking_army: Army, defending_army: Army) -> Array[int]:
	var attacker_efficiency: float = (
			modifier_request.modifiers(_context_attacker_efficiency).resultf()
	)
	var attacker_damage: int = floori(
			attacking_army.size().value * attacker_efficiency
	)

	var defender_efficiency: float = (
			modifier_request.modifiers(_context_defender_efficiency).resultf()
	)
	var defender_damage: int = floori(
			defending_army.size().value * defender_efficiency
	)

	return [attacker_damage, defender_damage]


func _algorithm_1(attacking_army: Army, defending_army: Army) -> Array[int]:
	var attacker_efficiency: float = (
			modifier_request.modifiers(_context_attacker_efficiency).resultf()
	)
	var attacker_damage: int = floori(
			attacking_army.size().value * attacker_efficiency
	)

	var defender_efficiency: float = (
			modifier_request.modifiers(_context_defender_efficiency).resultf()
	)
	var defender_damage: int = floori(
			defending_army.size().value * defender_efficiency
	)

	var fight_until_death: bool = true
	if fight_until_death:
		var attacker_kill_rate: float = (
				attacker_damage / float(defending_army.size().value)
		)
		var defender_kill_rate: float = (
				defender_damage / float(attacking_army.size().value)
		)
		if attacker_kill_rate > defender_kill_rate:
			attacker_damage = defending_army.size().value
			defender_damage = roundi(
					attacking_army.size().value
					* (defender_kill_rate / attacker_kill_rate)
			)
		else:
			defender_damage = attacking_army.size().value
			attacker_damage = roundi(
					defending_army.size().value
					* (attacker_kill_rate / defender_kill_rate)
			)

	return [attacker_damage, defender_damage]
