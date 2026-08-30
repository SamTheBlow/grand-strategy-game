class_name RecruitmentPopupFactory
extends Node

signal action_requested(action: Action)

const _RECRUITMENT_SCENE: PackedScene = preload("uid://dmta7gru0kbr2")

@export var _game_node: GameNode
@export var _popup_container: PopupContainer


## Opens the popup for when the user wants to recruit a new army.
func show_recruitment(province: Province) -> void:
	var recruitment: ArmyRecruitment = ArmyRecruitment.in_game(_game_node.game)
	if recruitment == null:
		return

	var popup := _RECRUITMENT_SCENE.instantiate() as RecruitmentPopup
	var recruitment_limits := ArmyRecruitmentLimits.new(
			_game_node.game, _game_node.game.turn.playing_country(), province
	)
	popup.setup(
			_game_node.game.world.provinces,
			province.id,
			[
				ResourceCost.new("Population", recruitment.population_per_unit),
				ResourceCost.new("Money", recruitment.money_per_unit)
			],
			recruitment_limits.minimum(),
			recruitment_limits.maximum()
	)
	popup.confirmed.connect(confirm_recruitment)
	popup.tree_exited.connect(
			_game_node.world_visuals.province_selection.deselect
	)
	_popup_container.add_popup(popup)


## Requests recruitment in given province.
func confirm_recruitment(troop_amount: int, province_id: int) -> void:
	action_requested.emit(ActionRecruitment.new(
			province_id,
			troop_amount,
			_game_node.game.world.armies.id_system().new_unique_id(false)
	))
