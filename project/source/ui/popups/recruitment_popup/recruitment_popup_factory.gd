class_name RecruitmentPopupFactory
extends Node
## Opens the popup for when the user wants to recruit a new army.

const _RECRUITMENT_SCENE: PackedScene = preload("uid://dmta7gru0kbr2")

@export var game_node: GameNode
@export var popup_container: PopupContainer


func show_recruitment(province: Province) -> void:
	var recruitment: ArmyRecruitment = ArmyRecruitment.in_game(game_node.game)
	if recruitment == null:
		return

	var popup := _RECRUITMENT_SCENE.instantiate() as RecruitmentPopup
	var recruitment_limits := ArmyRecruitmentLimits.new(
			game_node.game, game_node.game.turn.playing_country(), province
	)
	popup.setup(
			game_node.game.world.provinces,
			province.id,
			[
				ResourceCost.new("Population", recruitment.population_per_unit),
				ResourceCost.new("Money", recruitment.money_per_unit)
			],
			recruitment_limits.minimum(),
			recruitment_limits.maximum()
	)
	popup.confirmed.connect(game_node.confirm_recruitment)
	popup.tree_exited.connect(
			game_node.world_visuals.province_selection.deselect
	)
	popup_container.add_popup(popup)
