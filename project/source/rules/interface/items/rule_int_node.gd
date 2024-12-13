class_name RuleIntNode
extends RuleInterface

@export var rule: RuleInt

@onready var _label := %Label as Label
@onready var _spin_box := %SpinBox as SpinBox


func _ready() -> void:
	if not rule:
		push_error("Rule interface was not given a rule item.")
		return

	_label.text = rule.text
	_spin_box.value = rule.value
	_spin_box.value_changed.connect(_on_spin_box_value_changed)
	_spin_box.min_value = rule.minimum
	_spin_box.allow_lesser = not rule.has_minimum
	_spin_box.max_value = rule.maximum
	_spin_box.allow_greater = not rule.has_maximum

	_add_sub_rules(rule.sub_rules)
	rule.value_changed.connect(_on_rule_value_changed)


func _on_spin_box_value_changed(value: float) -> void:
	rule.value = roundi(value)


func _on_rule_value_changed(_rule: RuleItem) -> void:
	_spin_box.set_value_no_signal(rule.value)
