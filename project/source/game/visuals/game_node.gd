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
		game.turn.started.connect(_on_game_started)

## Reference to external node.
## May be null. If null, the players list will not be fully initialized.
## Please do not leave this null unless you're going to hide the UI.
var players: Players

## Reference to external node.
## May be null. If null, the chat interface is hidden.
var chat: Chat:
	set(value):
		chat = value
		chat.seed_requested.connect(_on_seed_requested)

## If false, the entire UI is hidden.
var is_ui_visible: bool = true:
	set(value):
		is_ui_visible = value
		_update_ui_visibility()

var _player_assignment: PlayerAssignment

@onready var world_visuals := %WorldVisuals2D as WorldVisuals2D

@onready var _ui_layer := %UILayer as CanvasLayer
@onready var _component_ui_container := %ComponentUI as ComponentUIContainer
@onready var _chat_interface := %ChatInterface as ChatInterface
@onready var _player_list := %PlayerList as PlayerList
@onready var _turn_order_list := %TurnOrderList as TurnOrderList
@onready var _build_fortress_popup_factory := %BuildFortressPopupFactory as BuildFortressPopupFactory
@onready var _recruitment_popup_factory := %RecruitmentPopupFactory as RecruitmentPopupFactory
@onready var _army_movement_popup_factory := %ArmyMovementPopupFactory as ArmyMovementPopupFactory
@onready var _game_over_popup_factory := %GameOverPopupFactory as GameOverPopupFactory


func _ready() -> void:
	_update_ui_visibility()

	world_visuals.project = project

	_component_ui_container.setup(
			game,
			world_visuals.province_visuals,
			world_visuals.province_selection
	)

	var networking_interface := (
			networking_setup_scene.instantiate() as NetworkingInterface
	)
	var game_sync := GameSync.new(game)

	if chat != null:
		_chat_interface.chat_data = chat.chat_data
		chat.connect_chat_interface(_chat_interface)
		chat.connect_networking_interface(networking_interface)
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

	_turn_order_list.countries = game.countries
	_turn_order_list.players = game.game_players
	_turn_order_list.game_turn = game.turn
	_turn_order_list.new_human_player_requested.connect(
			_on_new_human_player_requested
	)

	add_child(game_sync)

	if MultiplayerUtils.has_authority(multiplayer):
		game.setup_for_play()

		if players != null:
			_player_assignment.assign_players(players.list())

		game.start()


func _exit_tree() -> void:
	# Prevent the game from running forever in the background
	if game != null:
		game.turn.stop()


func _update_ui_visibility() -> void:
	if not is_node_ready():
		return

	_ui_layer.visible = is_ui_visible


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


func _on_game_started() -> void:
	if chat != null and MultiplayerUtils.has_authority(multiplayer):
		chat.send_global_message("The game has started!")


func _on_game_over(winning_country: Country) -> void:
	# Prevent crash
	if not is_node_ready():
		await ready

	_game_over_popup_factory.show_game_over(winning_country)

	if chat == null:
		return
	if winning_country == null:
		chat.send_global_message("The game is over!")
	else:
		chat.send_global_message(
				"The game is over! The winner is "
				+ winning_country.name_or_default() + "."
		)
	chat.send_global_message("You can continue playing if you want.")


## When attempting to select a province,
## instead opens the army movement popup (when applicable)
func _on_province_select_attempted(
		province: Province,
		outcome: ProvinceVisualsInput.ProvinceSelectionOutcome
) -> void:
	if not game.turn.is_running():
		return

	# Only open the popup if it's your turn
	var you: GamePlayer = game.turn.playing_players()[0]
	if not MultiplayerUtils.has_gameplay_authority(multiplayer, you):
		return

	var selected_province: Province = (
			world_visuals.province_selection.selected_province
	)
	if selected_province == null:
		return

	var my_active_armies_in_province: Array[Army] = (
			game.world.armies_in_each_province
			.dictionary[selected_province.id].ordered_list.duplicate()
	)
	for army: Army in my_active_armies_in_province.duplicate():
		if not (
				army.owner_country == game.turn.playing_country()
				and army.is_able_to_move()
		):
			my_active_armies_in_province.erase(army)

	if my_active_armies_in_province.size() > 0:
		# NOTE: assumes that countries only have
		# one active army per province
		var army: Army = my_active_armies_in_province[0]
		if army.can_move_to(game.world.provinces, province.id):
			_army_movement_popup_factory.show_army_movement(army, province)
			outcome.is_selected = false


func _on_component_ui_button_pressed(button_id: int) -> void:
	var selected_province: Province = (
			world_visuals.province_selection.selected_province
	)
	if selected_province == null:
		return

	# TODO bad code: hard coded values
	match button_id:
		0:
			# Build fortress
			_build_fortress_popup_factory.show_build_fortress(selected_province)
		1:
			# Recruitment
			_recruitment_popup_factory.show_recruitment(selected_province)


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
	game.setup_for_play()
	game.start()


func _on_player_list_player_added(player: Player) -> void:
	_player_assignment.assign_player(player)


func _on_new_human_player_requested(game_player: GamePlayer) -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		_add_player_and_assign(game_player)
	else:
		_receive_add_player_and_assign.rpc_id(1, game_player.id)


func _on_seed_requested() -> void:
	chat.send_system_message("Seed: " + project.game.rng.rng_seed)
