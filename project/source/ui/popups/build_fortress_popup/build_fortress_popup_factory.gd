class_name BuildFortressPopupFactory
extends Node

signal action_requested(action: Action)

const _BUILD_FORTRESS_SCENE: PackedScene = preload("uid://8rs6mtufs60s")

@export var _game_node: GameNode
@export var _popup_container: PopupContainer


## Opens the popup for when the user wants to build a fortress.
func show_build_fortress(province: Province) -> void:
	var popup := _BUILD_FORTRESS_SCENE.instantiate() as BuildFortressPopup
	var fortress_data: BuildingData = _game_node.game.world.fortress_data()
	popup.setup(
			_game_node.game.world.provinces,
			province.id,
			[
				ResourceCost.new("Population", fortress_data.population_cost),
				ResourceCost.new("Money", fortress_data.money_cost),
			]
	)
	popup.confirmed.connect(confirm_build_fortress)
	popup.tree_exited.connect(
			_game_node.world_visuals.province_selection.deselect
	)
	_popup_container.add_popup(popup)


## Requests to build a fortress in given province.
func confirm_build_fortress(province_id: int) -> void:
	action_requested.emit(ActionBuild.new(province_id))
