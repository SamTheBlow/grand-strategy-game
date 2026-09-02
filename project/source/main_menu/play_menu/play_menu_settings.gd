class_name PlayMenuSettings
extends Resource

signal state_changed(
		old_value: GameSelectMenuState, new_value: GameSelectMenuState
)

var game_select_menu_state := GameSelectMenuState.new():
	set(value):
		if game_select_menu_state == value:
			return
		var old_value: GameSelectMenuState = game_select_menu_state
		game_select_menu_state = value
		state_changed.emit(old_value, game_select_menu_state)
