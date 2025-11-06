class_name GameNode
extends Node
## Visuals for a given [GameProject].
# TODO bloated class

signal exited()

@export_group("Scenes")
@export var networking_setup_scene: PackedScene

@export_group("UI scenes")
@export var troop_ui_scene: PackedScene
@export var player_turn_scene: PackedScene
@export var player_list_scene: PackedScene
@export var popup_scene: PackedScene
@export var army_movement_scene: PackedScene
@export var game_over_scene: PackedScene
@export var build_fortress_scene: PackedScene
@export var recruitment_scene: PackedScene
@export var country_info_scene: PackedScene
@export var notification_info_scene: PackedScene

@export_group("Resources")
## Defines the outcome of a [Battle].
@export var battle: Battle

var project: GameProject:
	set(value):
		project = value
		game = project.game

## A reference to the project's game, for convenience. No need to set this:
## it's set automatically when setting the project variable.
var game: Game:
	set(value):
		game = value
		game.error_triggered.connect(_on_game_error)
		game.game_over.connect(_on_game_over)

## Reference to external node.
## May be null. If null, the players list will not be fully initialized.
## Please do not leave this null unless you're going to hide the UI.
var players: Players

## Reference to external node.
## May be null. If null, the chat interface is hidden.
var chat: Chat:
	set(value):
		chat = value

		chat.save_requested.connect(_on_save_requested)
		chat.load_requested.connect(_on_load_requested)
		chat.exit_to_main_menu_requested.connect(
				_on_exit_to_main_menu_requested
		)
		chat.rules_requested.connect(_on_chat_rules_requested)

## If false, the entire UI is hidden.
var is_ui_visible: bool = true:
	set(value):
		is_ui_visible = value
		_update_ui_visibility()

var _player_assignment: PlayerAssignment

@onready var world_visuals := %WorldVisuals2D as WorldVisuals2D

@onready var _camera := %Camera as CustomCamera2D
@onready var _ui_layer := %UILayer as CanvasLayer
@onready var _component_ui_container := %ComponentUI as ComponentUIContainer
@onready var _action_input := %ActionInput as ActionInput
@onready var _chat_interface := %ChatInterface as ChatInterface
@onready var _player_list := %PlayerList as PlayerList
@onready var _turn_order_list := %TurnOrderList as TurnOrderList
@onready var _popups := %Popups as Control
@onready var _pause_menu := %PauseMenu as Control


func _ready() -> void:
	_update_ui_visibility()
	_pause_menu.hide()

	_action_input.game = game

	world_visuals.project = project

	(%ProvinceSelectConditions as ProvinceSelectConditions).world_visuals = (
			world_visuals
	)

	_camera.world_limits = project.game.world.limits()
	_camera.move_to_world_center()

	_component_ui_container.setup(
			game,
			world_visuals.province_visuals,
			world_visuals.province_selection
	)
	_component_ui_container.button_pressed.connect(
			_on_component_ui_button_pressed
	)
	_component_ui_container.country_button_pressed.connect(
			_on_country_button_pressed
	)

	var networking_interface := (
			networking_setup_scene.instantiate() as NetworkingInterface
	)
	var game_sync := GameSync.new(game)

	if chat != null:
		# TODO bad code: private function
		networking_interface.message_sent.connect(
				chat._on_networking_interface_message_sent
		)
		_chat_interface.chat_data = chat.chat_data
		chat.connect_chat_interface(_chat_interface)
	else:
		_chat_interface.visible = false

	if players != null:
		_player_list.players = players
		_player_list.networking_interface = networking_interface
		_player_list.player_added.connect(_on_player_list_player_added)

		_turn_order_list.player_removal_requested.connect(players.remove_player)

		_player_assignment = PlayerAssignment.new(players, game.game_players)
		var player_assignment_sync := (
				PlayerAssignmentSync.new(_player_assignment)
		)
		game_sync.add_child(player_assignment_sync)

		if not MultiplayerUtils.has_authority(multiplayer):
			player_assignment_sync.sync_finished.connect(
					_on_player_assignment_sync_finished
			)
	else:
		_player_list.visible = false

	_turn_order_list.players = game.game_players
	_turn_order_list.game_turn = game.turn
	_turn_order_list.new_human_player_requested.connect(
			_on_new_human_player_requested
	)

	add_child(game_sync)

	if MultiplayerUtils.has_authority(multiplayer):
		if players != null:
			_player_assignment.assign_players(players.list())

		game.start()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pause"):
		_pause_menu.visible = not _pause_menu.visible


func _exit_tree() -> void:
	# Prevent the game from running forever in the background
	if game != null:
		game.turn.stop()


func _update_ui_visibility() -> void:
	if not is_node_ready():
		return

	_ui_layer.visible = is_ui_visible


## Opens the popup that appears when you want to build a fortress.
func _open_build_fortress_popup(province: Province) -> void:
	var build_fortress_popup := (
			build_fortress_scene.instantiate() as BuildFortressPopup
	)
	build_fortress_popup.setup(
			game.world.provinces,
			province.id,
			[ResourceCost.new("Money", game.rules.fortress_price.value)]
	)
	build_fortress_popup.confirmed.connect(_on_build_fortress_confirmed)
	build_fortress_popup.tree_exited.connect(_deselect_province)
	_add_popup(build_fortress_popup)


## Opens the popup that appears when you want to recruit a new army.
func _open_recruitment_popup(province: Province) -> void:
	var recruitment_popup := (
			recruitment_scene.instantiate() as RecruitmentPopup
	)
	var recruitment_limits := ArmyRecruitmentLimits.new(
			game, game.turn.playing_player().playing_country, province
	)
	recruitment_popup.setup(
			game.world.provinces,
			province.id,
			[
				ResourceCost.new(
						"Population",
						game.rules.recruitment_population_per_unit.value
				),
				ResourceCost.new(
						"Money",
						game.rules.recruitment_money_per_unit.value
				)
			],
			recruitment_limits.minimum(),
			recruitment_limits.maximum()
	)
	recruitment_popup.confirmed.connect(_on_recruitment_confirmed)
	recruitment_popup.tree_exited.connect(_deselect_province)
	_add_popup(recruitment_popup)


## Opens the popup that appears when you want to move an army.
func _open_army_movement_popup(army: Army, destination: Province) -> void:
	var army_movement_popup := (
			army_movement_scene.instantiate() as ArmyMovementPopup
	)
	army_movement_popup.setup(army, game.world.provinces, destination.id)
	army_movement_popup.confirmed.connect(_on_army_movement_confirmed)
	army_movement_popup.tree_exited.connect(_deselect_province)
	_add_popup(army_movement_popup)


## Adds a new [GamePopup] to the scene tree, containing given contents.
func _add_popup(contents: Node) -> void:
	var popup := popup_scene.instantiate() as GamePopup
	popup.contents_node = contents
	_popups.add_child(popup)


## Adds a new Player and assigns it to a specific GamePlayer.
func _add_player_and_assign(
		game_player: GamePlayer, multiplayer_id: int = 1
) -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		push_error(
				"Tried to add & assign a new player, "
				+ "but you do not have authority."
		)
		return

	if game_player == null:
		push_warning("Invalid GamePlayer id.")
		return
	if game_player.is_human and game_player.player_human != null:
		push_warning(
				"Tried to assign a new player to a GamePlayer that "
				+ "already has a player assigned to it."
		)
		return

	var new_player: Player = players.new_player(multiplayer_id)
	players.add_player(new_player)
	_player_assignment.assign_player_to(new_player, game_player)


func _deselect_province() -> void:
	world_visuals.province_selection.deselect()


## The server receives a client's request to add and assign a new player.
@rpc("any_peer", "call_remote", "reliable")
func _receive_add_player_and_assign(game_player_id: int) -> void:
	_add_player_and_assign(
			game.game_players.player_from_id(game_player_id),
			multiplayer.get_remote_sender_id()
	)


func _on_game_error(error_message: String) -> void:
	if chat == null:
		return
	chat.send_global_message(
			"[color=dark_red]Fatal error: \"" + error_message + "\"\n"
			+ "The game has stopped and cannot continue.[/color]"
	)


func _on_game_over(winning_country: Country) -> void:
	# Prevent crash
	if not is_node_ready():
		await ready

	var game_over_popup := game_over_scene.instantiate() as GameOverPopup
	game_over_popup.init(winning_country)
	_add_popup(game_over_popup)

	if chat == null:
		return
	chat.send_global_message(
			"The game is over! The winner is "
			+ winning_country.name_or_default() + "."
	)
	chat.send_global_message("You can continue playing if you want.")


## When attempting to select a province,
## instead opens the army movement popup (when applicable)
func _on_province_select_attempted(
		province: Province,
		outcome: ProvinceSelectConditions.ProvinceSelectionOutcome
) -> void:
	# Only open the popup if it's your turn
	var you: GamePlayer = game.turn.playing_player()
	if not MultiplayerUtils.has_gameplay_authority(multiplayer, you):
		return

	var selected_province: Province = (
			world_visuals.province_selection.selected_province()
	)
	if selected_province == null:
		return

	var my_active_armies_in_province: Array[Army] = (
			game.world.armies_in_each_province
			.in_province(selected_province).list.duplicate()
	)
	for army: Army in my_active_armies_in_province.duplicate():
		if not (
				army.owner_country == you.playing_country
				and army.is_able_to_move()
		):
			my_active_armies_in_province.erase(army)

	if my_active_armies_in_province.size() > 0:
		# NOTE: assumes that countries only have
		# one active army per province
		var army: Army = my_active_armies_in_province[0]
		if army.can_move_to(game.world.provinces, province.id):
			_open_army_movement_popup(army, province)
			outcome.is_selected = false


func _on_component_ui_button_pressed(button_id: int) -> void:
	var selected_province: Province = (
			world_visuals.province_selection.selected_province()
	)
	if selected_province == null:
		return

	# TODO bad code: hard coded values
	match button_id:
		0:
			# Build fortress
			_open_build_fortress_popup(selected_province)
		1:
			# Recruitment
			_open_recruitment_popup(selected_province)


func _on_end_turn_pressed() -> void:
	_action_input.apply_action(ActionEndTurn.new())


func _on_build_fortress_confirmed(province_id: int) -> void:
	_action_input.apply_action(ActionBuild.new(province_id))


func _on_recruitment_confirmed(troop_amount: int, province_id: int) -> void:
	_action_input.apply_action(ActionRecruitment.new(
			province_id,
			troop_amount,
			game.world.armies.id_system().new_unique_id(false)
	))


## Creates and applies army movement as a result of the user's actions.
func _on_army_movement_confirmed(
		army: Army,
		number_of_troops: int,
		destination_province_id: int
) -> void:
	var moving_army_id: int = army.id

	# Split the army into two if needed
	var army_size: int = army.army_size.current_size()
	if army_size > number_of_troops:
		var new_army_id: int = (
				game.world.armies.id_system().new_unique_id(false)
		)
		_action_input.apply_action(ActionArmySplit.new(
				army.id,
				[army_size - number_of_troops, number_of_troops],
				[new_army_id]
		))
		moving_army_id = new_army_id

	_action_input.apply_action(
			ActionArmyMovement.new(moving_army_id, destination_province_id)
	)


# Temporary feature
func _on_load_requested() -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		if chat != null:
			chat.send_system_message("Only the server can load a game!")
		return

	if chat != null:
		chat.send_system_message("Loading the save file...")

	get_parent().load_game()


func _on_save_requested() -> void:
	if chat != null:
		chat.send_system_message("Saving the game...")

	var project_save := ProjectSave.new()
	project_save.save_project(project)

	if project_save.error:
		var error_message: String = (
				"Saving failed: " + project_save.error_message
		)
		push_error(error_message)
		if chat != null:
			chat.send_system_message(error_message)
		return

	if chat != null:
		chat.send_system_message("[b]Game saved[/b]")


func _on_exit_to_main_menu_requested() -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		if chat != null:
			chat.send_system_message("Only the server can exit to main menu!")
		return

	exited.emit()


## Clients start the game when synchronization is finished.
func _on_player_assignment_sync_finished() -> void:
	game.start()


func _on_player_list_player_added(player: Player) -> void:
	_player_assignment.assign_player(player)


func _on_new_human_player_requested(game_player: GamePlayer) -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		_add_player_and_assign(game_player)
	else:
		_receive_add_player_and_assign.rpc_id(1, game_player.id)


func _on_chat_rules_requested() -> void:
	var lines: Array[String] = []
	lines.append("This game's rules:")
	for rule_name in GameRules.RULE_NAMES:
		var rule_data: Variant = game.rules.rule_with_name(rule_name).get_data()
		lines.append("-> " + rule_name + ": " + str(rule_data))
	chat.send_system_message_multiline(lines)


func _on_country_button_pressed(country: Country) -> void:
	var country_info := country_info_scene.instantiate() as CountryInfoPopup
	country_info.game_node = self
	country_info.country = country
	_add_popup(country_info)


func _on_diplomacy_action_pressed(
		diplomacy_action: DiplomacyAction,
		recipient_country: Country
) -> void:
	# TODO this check shouldn't be here...
	if (
			not MultiplayerUtils
			.has_gameplay_authority(multiplayer, game.turn.playing_player())
	):
		push_warning(
				"Tried to perform a diplomatic action, but"
				+ " the user does not have gameplay authority!"
		)
		return

	_action_input.apply_action(ActionDiplomacy.new(
			diplomacy_action.id(), recipient_country.id
	))


func _on_notification_pressed(game_notification: GameNotification) -> void:
	var notification_info := (
			notification_info_scene.instantiate() as NotificationInfoPopup
	)
	notification_info.game_notification = game_notification
	notification_info.decision_made.connect(_on_notification_decision_made)
	_add_popup(notification_info)


func _on_notification_dismissed(game_notification: GameNotification) -> void:
	_on_notification_decision_made(game_notification, -1)


func _on_notification_decision_made(
		game_notification: GameNotification, outcome_index: int
) -> void:
	# TASK this check shouldn't be here... also DRY: this is a copy/paste
	if (
			not MultiplayerUtils
			.has_gameplay_authority(multiplayer, game.turn.playing_player())
	):
		push_warning(
				"Tried to handle a game notification, but"
				+ " the user does not have gameplay authority!"
		)
		return

	_action_input.apply_action(ActionHandleNotification.new(
			game_notification.id, outcome_index
	))


func _on_pause_menu_resume_pressed() -> void:
	_pause_menu.hide()


func _on_pause_menu_save_pressed() -> void:
	_on_save_requested()


func _on_pause_menu_quit_pressed() -> void:
	_on_exit_to_main_menu_requested()


func _on_pause_menu_save_and_quit_pressed() -> void:
	_on_save_requested()
	_on_exit_to_main_menu_requested()
