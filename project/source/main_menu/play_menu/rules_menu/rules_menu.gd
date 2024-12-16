class_name RulesMenu
extends RuleInterface
## Root node for all the settings that let you change the game's rules.
## Generates all the settings nodes, and initializes a [RulesMenuSync].

var game_rules: GameRules:
	set = set_game_rules

@onready var _sync := %RulesMenuSync as RulesMenuSync


func _ready() -> void:
	_update()


func set_game_rules(value: GameRules) -> void:
	game_rules = value
	_update()


func _update() -> void:
	if game_rules == null or not is_node_ready():
		return

	_sync.active_state = game_rules
	# Only set the current state as the local state
	# the first time this function is called.
	if _sync.local_state == null:
		_sync.local_state = game_rules

	_clear()
	_add_sub_rules(game_rules.root_rules, true, false)
