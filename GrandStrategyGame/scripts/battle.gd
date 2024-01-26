class_name Battle
extends Resource


@export var _context_attacker_efficiency: ModifierContext
@export var _context_defender_efficiency: ModifierContext

var attacking_army: Army
var defending_army: Army


func apply(modifier_mediator: ModifierMediator) -> void:
	#print("A battle is about to begin!")
	
	_context_attacker_efficiency._defending_army = defending_army
	
	var attacker_army_size: int = attacking_army.army_size.current_size()
	# TODO base efficiency 0.9 in global modifiers
	var attacker_efficiency: float = (
			modifier_mediator.modifiers(_context_attacker_efficiency).resultf()
	)
	var attacker_damage: int = floori(attacker_army_size * attacker_efficiency)
	
	var defender_army_size: int = defending_army.army_size.current_size()
	var defender_efficiency: float = (
			modifier_mediator.modifiers(_context_defender_efficiency).resultf()
	)
	var defender_damage: int = floori(defender_army_size * defender_efficiency)
	
	# The attacker attacks first
	print("=====\nA battle occurs!")
	print("Attacker %s (%s) has army size of %s" % [attacking_army.owner_country().country_name, attacking_army.id, attacker_army_size])
	print("Defender %s (%s) has army size of %s" % [defending_army.owner_country().country_name, defending_army.id, defender_army_size])
	print("Attacker deals %s damage! Attacker efficiency: %s" % [attacker_damage, attacker_efficiency])
	defending_army.army_size.remove(attacker_damage)
	print("Defender army size is down to %s" % defending_army.army_size.current_size())
	print("Defender deals %s damage! Defender efficiency: %s" % [defender_damage, defender_efficiency])
	attacking_army.army_size.remove(defender_damage)
	print("Attacker army size is down to %s" % attacking_army.army_size.current_size())
