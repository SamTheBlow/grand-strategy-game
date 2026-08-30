class_name ArmyMovementPopupFactory
extends Node
## Opens the popup for when the user wants to move an army.

const _ARMY_MOVEMENT_SCENE: PackedScene = preload("uid://db07kg52gllnd")

@export var game_node: GameNode
@export var popup_container: PopupContainer


func show_army_movement(army: Army, destination: Province) -> void:
	var popup := _ARMY_MOVEMENT_SCENE.instantiate() as ArmyMovementPopup
	popup.setup(army, game_node.game.world.provinces, destination.id)
	popup.confirmed.connect(game_node.confirm_army_movement)
	popup.tree_exited.connect(
			game_node.world_visuals.province_selection.deselect
	)
	popup_container.add_popup(popup)
