class_name DiplomacyActionButton
extends Control
## Note: this node automatically hides itself if it has invalid/missing info.


signal pressed(diplomacy_action: DiplomacyAction)

var diplomacy_action: DiplomacyAction:
	set(value):
		diplomacy_action = value
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
	
	_name_label.text = diplomacy_action._definition.name
	var turns_remaining: int = diplomacy_action.cooldown_turns_remaining(game)
	_disabled_label.text = (
			"Available in "
			+ str(turns_remaining)
			+ " turn" + ("s" if turns_remaining != 1 else "")
	)
	
	_set_is_disabled(not diplomacy_action.can_be_performed(game))
	show()


func _set_is_disabled(is_disabled: bool) -> void:
	_button.visible = not is_disabled
	_disabled.visible = is_disabled


func _on_button_pressed() -> void:
	if diplomacy_action == null:
		return
	
	pressed.emit(diplomacy_action)
