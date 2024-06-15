class_name RuleBoolNode
extends RuleInterface


@export var rule: RuleBool

var _sub_rule_nodes_on: Array[Control] = []
var _sub_rule_nodes_off: Array[Control] = []

@onready var _label := %Label as Label
@onready var _check_box := %CheckBox as CheckBox


func _ready() -> void:
	if not rule:
		push_error("Rule interface was not given a rule item.")
		return
	
	_label.text = rule.text
	_check_box.button_pressed = rule.value
	_check_box.toggled.connect(_on_check_box_toggled)
	
	_add_sub_rules(rule.sub_rules)
	
	for i in range(1, _container.get_children().size()):
		if rule.sub_rules_on.has(i - 1):
			_sub_rule_nodes_on.append(_container.get_child(i))
			continue
		if rule.sub_rules_off.has(i - 1):
			_sub_rule_nodes_off.append(_container.get_child(i))
	_update_sub_rule_visibility()
	
	rule.value_changed.connect(_on_rule_value_changed)


func _update_sub_rule_visibility() -> void:
	for control in _sub_rule_nodes_on:
		control.visible = rule.value
	for control in _sub_rule_nodes_off:
		control.visible = not rule.value


func _on_check_box_toggled(toggled_on: bool) -> void:
	rule.value = toggled_on
	_update_sub_rule_visibility()


func _on_rule_value_changed(_rule: RuleItem) -> void:
	_check_box.set_pressed_no_signal(rule.value)
	_update_sub_rule_visibility()
