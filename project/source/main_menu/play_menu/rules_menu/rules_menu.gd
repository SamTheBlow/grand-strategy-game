@tool
class_name RulesMenu
extends PropertyTreeNode
## Root node for all the settings that let you change the game's rules.
## Generates all the settings nodes, and initializes a [RulesMenuSync].

var game_rules: GameRules:
	set = set_game_rules

@onready var _sync := %RulesMenuSync as RulesMenuSync


func _ready() -> void:
	refresh()


func set_game_rules(value: GameRules) -> void:
	game_rules = value
	refresh()


func refresh() -> void:
	if not is_node_ready() or game_rules == null:
		return

	_sync.active_state = game_rules
	# Only set the current state as the local state
	# the first time this function is called.
	if _sync.local_state == null:
		_sync.local_state = game_rules

	_clear()
	_add_child_items(game_rules.root_rules, true, false)
