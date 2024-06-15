class_name RuleRangeIntNode
extends RuleInterface
## Note that the text property has no effect on this node.


@export var rule: RuleRangeInt

@onready var _from_spin_box := %FromSpinBox as SpinBox
@onready var _to_spin_box := %ToSpinBox as SpinBox


func _ready() -> void:
	if not rule:
		push_error("Rule interface was not given a rule item.")
		return
	
	_from_spin_box.value = rule.min_value
	_from_spin_box.value_changed.connect(_on_from_spin_box_value_changed)
	_from_spin_box.min_value = rule.minimum
	_from_spin_box.allow_lesser = not rule.has_minimum
	_from_spin_box.max_value = rule.maximum
	_from_spin_box.allow_greater = not rule.has_maximum
	
	_to_spin_box.value = rule.max_value
	_to_spin_box.value_changed.connect(_on_to_spin_box_value_changed)
	_to_spin_box.min_value = rule.minimum
	_to_spin_box.allow_lesser = not rule.has_minimum
	_to_spin_box.max_value = rule.maximum
	_to_spin_box.allow_greater = not rule.has_maximum
	
	_add_sub_rules(rule.sub_rules)
	rule.value_changed.connect(_on_rule_value_changed)


func _on_from_spin_box_value_changed(value: float) -> void:
	rule.min_value = roundi(value)


func _on_to_spin_box_value_changed(value: float) -> void:
	rule.max_value = roundi(value)


func _on_rule_value_changed(_rule: RuleItem) -> void:
	_from_spin_box.set_value_no_signal(rule.min_value)
	_to_spin_box.set_value_no_signal(rule.max_value)
