class_name PopupContainer
extends Control
## Creates popups that may appear during a game.
##
## See also: [GamePopup]

const _POPUP_SCENE: PackedScene = preload("uid://by865efl4iwy")

const _COUNTRY_INFO_SCENE: PackedScene = preload("uid://2hy14ir4o0ps")
const _BUILD_FORTRESS_SCENE: PackedScene = preload("uid://8rs6mtufs60s")
const _RECRUITMENT_SCENE: PackedScene = preload("uid://dmta7gru0kbr2")
const _ARMY_MOVEMENT_SCENE: PackedScene = preload("uid://db07kg52gllnd")
const _GAME_OVER_SCENE: PackedScene = preload("uid://cfhpg688geojo")
const _NOTIFICATION_INFO_SCENE: PackedScene = preload("uid://crnnhfnswkmub")

@export var _game_node: GameNode


## Opens a popup with information about given country.
func show_country_info(country: Country) -> void:
	var popup := _COUNTRY_INFO_SCENE.instantiate() as CountryInfoPopup
	popup.setup(_game_node.game, country)
	popup.diplomacy_action_requested.connect(
			_game_node.confirm_diplomacy_action
	)
	_add_popup(popup)


## Opens the popup for when user wants to build a fortress.
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
	popup.confirmed.connect(_game_node.confirm_build_fortress)
	popup.tree_exited.connect(
			_game_node.world_visuals.province_selection.deselect
	)
	_add_popup(popup)


## Opens the popup for when user wants to recruit a new army.
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
	popup.confirmed.connect(_game_node.confirm_recruitment)
	popup.tree_exited.connect(
			_game_node.world_visuals.province_selection.deselect
	)
	_add_popup(popup)


## Opens the popup for when user wants to move an army.
func show_army_movement(army: Army, destination: Province) -> void:
	var popup := _ARMY_MOVEMENT_SCENE.instantiate() as ArmyMovementPopup
	popup.setup(army, _game_node.game.world.provinces, destination.id)
	popup.confirmed.connect(_game_node.confirm_army_movement)
	popup.tree_exited.connect(
			_game_node.world_visuals.province_selection.deselect
	)
	_add_popup(popup)


## Opens the popup for when the game is over.
func show_game_over(winning_country: Country) -> void:
	var popup := _GAME_OVER_SCENE.instantiate() as GameOverPopup
	popup.setup(winning_country)
	_add_popup(popup)


## Opens a popup with information about given notification.
func show_notification_info(game_notification: GameNotification) -> void:
	var popup := _NOTIFICATION_INFO_SCENE.instantiate() as NotificationInfoPopup
	popup.game_notification = game_notification
	popup.decision_made.connect(_game_node.confirm_notification_decision)
	_add_popup(popup)


func _add_popup(contents: Node) -> void:
	var popup := _POPUP_SCENE.instantiate() as GamePopup
	popup.contents_node = contents
	add_child(popup)
