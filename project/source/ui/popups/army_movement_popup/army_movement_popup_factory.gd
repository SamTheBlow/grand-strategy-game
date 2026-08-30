class_name ArmyMovementPopupFactory
extends Node

signal action_requested(action: Action)

const _ARMY_MOVEMENT_SCENE: PackedScene = preload("uid://db07kg52gllnd")

@export var _game_node: GameNode
@export var _popup_container: PopupContainer


## Opens the popup for when the user wants to move an army.
func show_army_movement(army: Army, destination: Province) -> void:
	var popup := _ARMY_MOVEMENT_SCENE.instantiate() as ArmyMovementPopup
	popup.setup(army, _game_node.game.world.provinces, destination.id)
	popup.confirmed.connect(confirm_army_movement)
	popup.tree_exited.connect(
			_game_node.world_visuals.province_selection.deselect
	)
	_popup_container.add_popup(popup)


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
