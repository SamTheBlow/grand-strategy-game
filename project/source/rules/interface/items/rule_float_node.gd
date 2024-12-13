class_name RuleFloatNode
extends RuleInterface

@export var rule: RuleFloat

@onready var _label := %Label as Label
@onready var _spin_box := %SpinBox as SpinBox


func _ready() -> void:
	if not rule:
		push_error("Rule interface was not given a rule item.")
		return

	if rule.is_percentage:
		_spin_box.custom_arrow_step = 0.01
		_spin_box.value = rule.value * 100.0
		_spin_box.min_value = rule.minimum * 100.0
		_spin_box.max_value = rule.maximum * 100.0
	else:
		_spin_box.value = rule.value
		_spin_box.min_value = rule.minimum
		_spin_box.max_value = rule.maximum

	_label.text = rule.text
	_spin_box.value_changed.connect(_on_spin_box_value_changed)
	_spin_box.allow_lesser = not rule.has_minimum
	_spin_box.allow_greater = not rule.has_maximum

	_add_sub_rules(rule.sub_rules)
	rule.value_changed.connect(_on_rule_value_changed)


func _on_spin_box_value_changed(value: float) -> void:
	if rule.is_percentage:
		rule.value = value * 0.01
	else:
		rule.value = value


func _on_rule_value_changed(_rule: RuleItem) -> void:
	if rule.is_percentage:
		_spin_box.set_value_no_signal(rule.value * 100.0)
	else:
		_spin_box.set_value_no_signal(rule.value)
