class_name DiplomacyActionButton
extends Control
## Button for given [DiplomacyAction].
## If the action cannot be performed, disables the button
## and shows a message explaining why.
## Hides itself if either diplomacy_action or game is null.

signal pressed(diplomacy_action: DiplomacyAction)

var diplomacy_action: DiplomacyAction:
	set(value):
		_disconnect_signals()
		diplomacy_action = value
		_connect_signals()
		_refresh()

var game: Game:
	set(value):
		game = value
		_refresh()

@onready var _button := %Button as Button
@onready var _name_label := %NameLabel as Label
@onready var _disabled := %Disabled as Control
@onready var _disabled_label := %DisabledLabel as Label


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return

	if diplomacy_action == null or game == null:
		hide()
		return

	# TODO bad code: private member access
	_name_label.text = diplomacy_action._definition.name

	_refresh_is_disabled()
	show()


func _refresh_is_disabled() -> void:
	var is_disabled: bool = not diplomacy_action.can_be_performed(game)

	_button.visible = not is_disabled
	_disabled.visible = is_disabled

	if not is_disabled:
		return

	var turns_remaining: int = diplomacy_action.cooldown_turns_remaining(game)
	if diplomacy_action.was_performed_this_turn():
		_disabled_label.text = "Done!"
	elif turns_remaining > 0:
		_disabled_label.text = (
				"Available in "
				+ str(turns_remaining)
				+ " turn" + ("s" if turns_remaining != 1 else "")
		)


func _disconnect_signals() -> void:
	if diplomacy_action == null:
		return

	if diplomacy_action.performed.is_connected(_on_action_performed):
		diplomacy_action.performed.disconnect(_on_action_performed)


func _connect_signals() -> void:
	if diplomacy_action == null:
		return

	if not diplomacy_action.performed.is_connected(_on_action_performed):
		diplomacy_action.performed.connect(_on_action_performed)


func _on_button_pressed() -> void:
	if diplomacy_action == null:
		return

	pressed.emit(diplomacy_action)


func _on_action_performed(_diplomacy_action: DiplomacyAction) -> void:
	_refresh_is_disabled()
