class_name RulesMenuSync
extends Node
## Synchronizes a given instance of [GameRules] between network clients.
## When leaving a server, resets the entire state to what it was before joining.
##
## See also: [MapMenuSync]


## Emitted on clients when the client receives a new state from the server,
## in which case this signal will pass a new instance of [GameRules].
## Also emitted on clients when the client disconnects from a server,
## in which case this signal will pass a reference to the user's local state.
signal state_changed(new_state: GameRules)


## This is the state that's being used by the UI.
## Changing something in this object will affect the visuals.
var active_state: GameRules:
	set(value):
		if active_state == value:
			return

		_disconnect_signals()
		active_state = value
		_connect_signals()

		_send_active_state_to_clients()

## This is the user's personal state.
## It stops being the active state when joining a server.
## It becomes the active state again when leaving a server.
var local_state: GameRules


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	_send_active_state_to_clients()


func _connect_signals() -> void:
	if active_state == null:
		return

	if (
			not active_state.rule_changed
			.is_connected(_on_rule_changed)
	):
		active_state.rule_changed.connect(_on_rule_changed)


func _disconnect_signals() -> void:
	if active_state == null:
		return

	if (
			active_state.rule_changed
			.is_connected(_on_rule_changed)
	):
		active_state.rule_changed.disconnect(_on_rule_changed)


## Sends the active state to all clients.
## Only works when you're the server.
func _send_active_state_to_clients() -> void:
	if active_state == null or not is_node_ready():
		return

	if MultiplayerUtils.is_server(multiplayer):
		_receive_state.rpc(RulesToRawDict.new().result(active_state))


## Updates the entire state on clients.
@rpc("authority", "call_remote", "reliable")
func _receive_state(data: Dictionary) -> void:
	state_changed.emit(RulesFromRawDict.new().result(data))


## Updates a rule on clients.
@rpc("authority", "call_remote", "reliable")
func _receive_rule_changed(rule_name: String, rule_value: Variant) -> void:
	var rule_item: RuleItem = active_state.rule_with_name(rule_name)
	if rule_item == null:
		return
	rule_item.set_data(rule_value)


## On the server, sends the rule change to all clients.
func _on_rule_changed(rule_name: String, rule_item: RuleItem) -> void:
	if MultiplayerUtils.is_server(multiplayer):
		_receive_rule_changed.rpc(rule_name, rule_item.get_data())


## On the server, sends the current state to the new client.
func _on_peer_connected(peer_id: int) -> void:
	if MultiplayerUtils.is_server(multiplayer):
		_receive_state.rpc_id(
				peer_id, RulesToRawDict.new().result(active_state)
		)


## Resets the menu's state on disconnected clients.
func _on_server_disconnected() -> void:
	state_changed.emit(local_state)
