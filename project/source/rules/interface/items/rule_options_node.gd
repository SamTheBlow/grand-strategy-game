class_name RuleOptionsNode
extends RuleInterface


@export var rule: RuleOptions

@onready var _label := %Label as Label
@onready var _option_button := %CustomOptionButton as CustomOptionButton


func _ready() -> void:
	if not rule:
		push_error("Rule interface was not given a rule item.")
		return
	
	_label.text = rule.text
	for option_name in rule.options:
		_option_button.add_item(option_name)
	
	_add_sub_rules(rule.sub_rules)
	
	# Setup the [CustomOptionButton]'s filters
	var container_children: Array[Node] = _container.get_children()
	for rule_option_filter in rule.option_filters:
		var node_option_filter: Array[Control] = []
		for i in rule_option_filter.size():
			node_option_filter.append(
					container_children[rule_option_filter[i] + 1]
			)
		_option_button.option_filters.append(node_option_filter)
	
	_option_button.select_item(rule.selected_index)
	_option_button.item_selected.connect(_on_item_selected)
	rule.value_changed.connect(_on_rule_value_changed)


func _on_item_selected(selected: int) -> void:
	rule.selected_index = selected


func _on_rule_value_changed(_rule: RuleItem) -> void:
	_option_button.select_item(rule.selected_index)
