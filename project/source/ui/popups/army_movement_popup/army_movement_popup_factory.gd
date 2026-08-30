class_name ArmyMovementPopupFactory
extends Node

signal action_requested(action: Action)

const _ARMY_MOVEMENT_SCENE: PackedScene = preload("uid://db07kg52gllnd")

@export var _game_node: GameNode
@export var _popup_container: PopupContainer


## When attempting to select a province,
## instead opens the army movement popup, when applicable.
func check_open_popup(
		province: Province,
		outcome: ProvinceVisualsInput.ProvinceSelectionOutcome
) -> void:
	if not _game_node.game.turn.is_running():
		return

	# Only open the popup if it's your turn
	var you: GamePlayer = _game_node.game.turn.playing_players()[0]
	if not MultiplayerUtils.has_gameplay_authority(_game_node.multiplayer, you):
		return

	var selected_province: Province = (
			_game_node.world_visuals.province_selection.selected_province
	)
	if selected_province == null:
		return

	var my_active_armies_in_province: Array[Army] = (
			_game_node.game.world.armies_in_each_province
			.dictionary[selected_province.id].ordered_list.duplicate()
	)
	for army: Army in my_active_armies_in_province.duplicate():
		if not (
				army.owner_country == _game_node.game.turn.playing_country()
				and army.is_able_to_move()
		):
			my_active_armies_in_province.erase(army)

	if my_active_armies_in_province.size() > 0:
		# NOTE: assumes that countries only have one active army per province
		var army: Army = my_active_armies_in_province[0]
		if army.can_move_to(_game_node.game.world.provinces, province.id):
			_create_popup(army, province)
			outcome.is_selected = false


## Creates and requests army movement as a result of the user's actions.
func confirm_army_movement(
		army: Army, number_of_troops: int, destination_province_id: int
) -> void:
	var moving_army_id: int = army.id

	# Split the army into two if needed
	if army.size().value > number_of_troops:
		var new_army_id: int = (
				_game_node.game.world.armies.id_system().new_unique_id(false)
		)
		action_requested.emit(ActionArmySplit.new(
				army.id,
				[army.size().value - number_of_troops, number_of_troops],
				[new_army_id]
		))
		moving_army_id = new_army_id

	action_requested.emit(
			ActionArmyMovement.new(moving_army_id, destination_province_id)
	)


## Opens the popup for when the user wants to move an army.
func _create_popup(army: Army, destination: Province) -> void:
	var popup := _ARMY_MOVEMENT_SCENE.instantiate() as ArmyMovementPopup
	popup.setup(army, _game_node.game.world.provinces, destination.id)
	popup.confirmed.connect(confirm_army_movement)
	popup.tree_exited.connect(
			_game_node.world_visuals.province_selection.deselect
	)
	_popup_container.add_popup(popup)
