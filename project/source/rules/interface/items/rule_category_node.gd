class_name RuleCategoryNode
extends RuleInterface

@export var rule: RuleItem

@onready var _label := %Label as Label


func _ready() -> void:
	if not rule:
		push_error("Rule interface was not given a rule item.")
		return

	_label.text = rule.text

	_add_sub_rules(rule.sub_rules)
