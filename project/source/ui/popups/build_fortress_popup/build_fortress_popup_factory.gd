class_name BuildFortressPopupFactory
extends Node
## Opens the popup for when the user wants to build a fortress.

const _BUILD_FORTRESS_SCENE: PackedScene = preload("uid://8rs6mtufs60s")

@export var game_node: GameNode
@export var popup_container: PopupContainer


func show_build_fortress(province: Province) -> void:
	var popup := _BUILD_FORTRESS_SCENE.instantiate() as BuildFortressPopup
	var fortress_data: BuildingData = game_node.game.world.fortress_data()
	popup.setup(
			game_node.game.world.provinces,
			province.id,
			[
				ResourceCost.new("Population", fortress_data.population_cost),
				ResourceCost.new("Money", fortress_data.money_cost),
			]
	)
	popup.confirmed.connect(game_node.confirm_build_fortress)
	popup.tree_exited.connect(
			game_node.world_visuals.province_selection.deselect
	)
	popup_container.add_popup(popup)
