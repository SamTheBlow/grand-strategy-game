class_name ComponentUIButtonHandler
extends Node
## Handles button presses from some [ComponentUI].

signal build_fortress_requested(province: Province)
signal recruit_requested(province: Province)

enum ButtonAction {
	BUILD_FORTRESS,
	RECRUIT,
}

@export var _game_node: GameNode


func handle_button_press(button_id: int) -> void:
	var selected_province: Province = (
			_game_node.world_visuals.province_selection.selected_province
	)
	if selected_province == null:
		return

	match button_id:
		ButtonAction.BUILD_FORTRESS:
			build_fortress_requested.emit(selected_province)
		ButtonAction.RECRUIT:
			recruit_requested.emit(selected_province)
