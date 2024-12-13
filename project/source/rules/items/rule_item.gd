@tool
class_name RuleItem
extends Resource
## Base class for a game rule.
## Extend this class to add functionality.
##
## See also: [GameRules]

@export var text: String = ""

var sub_rules: Array[RuleItem] = []

var _is_locked: bool = false


## Locks this rule and all of its subrules.
## When a rule is locked, it cannot be changed anymore.
func lock() -> void:
	_is_locked = true
	for sub_rule in sub_rules:
		sub_rule.lock()


## This rule's variable information, for the purpose of saving/loading.
## If this rule item does not have one, this returns null.
func get_data() -> Variant:
	return null


func set_data(_data: Variant) -> void:
	pass
