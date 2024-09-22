class_name GameNode
extends Node
## Visuals for a given [Game].
# TODO bloated class


signal exited()

@export_group("Scenes")
@export var networking_setup_scene: PackedScene

@export_group("UI scenes")
@export var troop_ui_scene: PackedScene
@export var component_ui_scene: PackedScene
@export var player_turn_scene: PackedScene
@export var player_list_scene: PackedScene
@export var popup_scene: PackedScene
@export var army_movement_scene: PackedScene
@export var game_over_scene: PackedScene
@export var build_fortress_scene: PackedScene
@export var recruitment_scene: PackedScene
@export var country_info_scene: PackedScene
@export var notification_info_scene: PackedScene

@export_group("Children")
@export var camera: CustomCamera2D
@export var component_ui_root: Control
@export var popups: Control

@export_group("Resources")
## Defines the outcome of a [Battle].
@export var battle: Battle
## Icon to use for [GameNotificationOfferAccepted].
@export var offer_accepted_icon: Texture2D


var game: Game:
	set(value):
		game = value
		game.game_over.connect(_on_game_over)
		game.offer_accepted_icon = offer_accepted_icon

## Reference to external node
var chat: Chat:
	get:
		if chat == null:
			push_error("Chat is null. Setting it to a new instance.")
			chat = Chat.new()
		return chat
	set(value):
		chat = value
		
		chat.save_requested.connect(_on_save_requested)
		chat.load_requested.connect(_on_load_requested)
		chat.exit_to_main_menu_requested.connect(
				_on_exit_to_main_menu_requested
		)
		chat.rules_requested.connect(_on_chat_rules_requested)

@onready var world_visuals := %WorldVisuals2D as WorldVisuals2D

@onready var _action_input := %ActionInput as ActionInput
@onready var _chat_interface := %ChatInterface as ChatInterface
@onready var _player_list := %PlayerList as PlayerList
@onready var _turn_order_list := %TurnOrderList as TurnOrderList


func _ready() -> void:
	if game.world is not GameWorld2D:
		return
	var world_2d := game.world as GameWorld2D
	
	_action_input.game = game
	
	world_visuals.game = game
	world_visuals.world = world_2d
	world_visuals.province_visuals.province_selected.connect(
			_on_province_selected
	)
	world_visuals.province_visuals.unhandled_mouse_event_occured.connect(
			_on_province_unhandled_mouse_event
	)
	
	camera.world_limits = world_2d.limits
	
	var networking_interface := (
			networking_setup_scene.instantiate() as NetworkingInterface
	)
	# TODO bad code: private function
	networking_interface.message_sent.connect(
			chat._on_networking_interface_message_sent
	)
	_player_list.networking_interface = networking_interface
	
	_chat_interface.chat_data = chat.chat_data
	chat.connect_chat_interface(_chat_interface)
	
	_turn_order_list.players = game.game_players
	_turn_order_list.game_turn = game.turn


func set_players(players: Players) -> void:
	if not is_node_ready():
		await ready
	_player_list.players = players
	_turn_order_list.player_removal_requested.connect(players.remove_player)


## Creates and applies army movement as a result of the user's actions.
func new_action_army_movement(
		army: Army,
		number_of_troops: int,
		destination_province: Province
) -> void:
	var moving_army_id: int = army.id
	
	# Split the army into two if needed
	var army_size: int = army.army_size.current_size()
	if army_size > number_of_troops:
		var new_army_id: int = game.world.armies.new_unique_id()
		var action_split := ActionArmySplit.new(
				army.id,
				[army_size - number_of_troops, number_of_troops],
				[new_army_id]
		)
		_action_input.apply_action(action_split)
		
		moving_army_id = new_army_id
	
	var action_move := ActionArmyMovement.new(
			moving_army_id, destination_province.id
	)
	_action_input.apply_action(action_move)


## Creates the popup that appears when you want to move an [Army].
func _add_army_movement_popup(army: Army, destination: Province) -> void:
	var army_movement_popup := (
			army_movement_scene.instantiate() as ArmyMovementPopup
	)
	army_movement_popup.init(army, destination)
	army_movement_popup.confirmed.connect(new_action_army_movement)
	army_movement_popup.tree_exited.connect(_on_army_movement_closed)
	_add_popup(army_movement_popup)


## Adds a new [GamePopup] to the scene tree, containing given contents.
func _add_popup(contents: Node) -> void:
	var popup := popup_scene.instantiate() as GamePopup
	popup.contents_node = contents
	popups.add_child(popup)


func _on_game_over(winning_country: Country) -> void:
	var game_over_popup := game_over_scene.instantiate() as GameOverPopup
	game_over_popup.init(winning_country)
	_add_popup(game_over_popup)
	
	chat.send_global_message(
			"The game is over! The winner is "
			+ str(winning_country.country_name) + "."
	)
	chat.send_global_message("You can continue playing if you want.")


## When left clicking on a province, selects the province
## or opens an army movement popup when applicable
func _on_province_unhandled_mouse_event(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
) -> void:
	# Only proceed when the input is a left click
	if not (event is InputEventMouseButton):
		return
	var event_button := event as InputEventMouseButton
	if not (
			event_button.pressed
			and event_button.button_index == MOUSE_BUTTON_LEFT
	):
		return
	get_viewport().set_input_as_handled()
	
	var province: Province = province_visuals.province
	var you: GamePlayer = game.turn.playing_player()
	
	# You're not the one playing? Select province and return
	if not MultiplayerUtils.has_gameplay_authority(multiplayer, you):
		world_visuals.province_selection.selected_province = province
		return
	
	# If applicable, open the army movement popup
	var selected_province: Province = (
			world_visuals.province_selection.selected_province
	)
	if selected_province != null:
		var active_armies: Array[Army] = game.world.armies.active_armies(
				you.playing_country, selected_province
		)
		if active_armies.size() > 0:
			# NOTE: assumes that countries only have one active army per province
			var army: Army = active_armies[0]
			if army.can_move_to(province):
				_add_army_movement_popup(army, province)
				return
	
	world_visuals.province_selection.selected_province = province


func _on_province_selected(province_visuals: ProvinceVisuals2D) -> void:
	var component_ui := component_ui_scene.instantiate() as ComponentUI
	component_ui.game = game
	component_ui.province_visuals = province_visuals
	component_ui.button_pressed.connect(_on_component_ui_button_pressed)
	component_ui.connect_country_button_pressed(_on_country_button_pressed)
	component_ui_root.add_child(component_ui)


func _on_component_ui_button_pressed(button_id: int) -> void:
	var selected_province: Province = (
			world_visuals.province_selection.selected_province
	)
	
	# TODO bad code: hard coded values
	match button_id:
		0:
			# Build fortress
			var build_popup := (
					build_fortress_scene.instantiate() as BuildFortressPopup
			)
			build_popup.province = selected_province
			build_popup.set_population_cost(ResourceCost.new(0))
			build_popup.set_money_cost(ResourceCost.new(
					game.rules.fortress_price.value
			))
			build_popup.confirmed.connect(_on_build_fortress_confirmed)
			_add_popup(build_popup)
		1:
			# Recruitment
			var recruitment_popup := (
					recruitment_scene.instantiate() as RecruitmentPopup
			)
			recruitment_popup.province = selected_province
			
			var recruitment_limits := ArmyRecruitmentLimits.new(
					game.turn.playing_player().playing_country,
					selected_province,
					game
			)
			recruitment_popup.set_minimum_amount(recruitment_limits.minimum())
			recruitment_popup.set_maximum_amount(recruitment_limits.maximum())
			
			recruitment_popup.set_population_cost(ResourceCost.new(
					game.rules.recruitment_population_per_unit.value
			))
			recruitment_popup.set_money_cost(ResourceCost.new(
					game.rules.recruitment_money_per_unit.value
			))
			recruitment_popup.confirmed.connect(_on_recruitment_confirmed)
			_add_popup(recruitment_popup)


func _on_end_turn_pressed() -> void:
	_action_input.apply_action(ActionEndTurn.new())


func _on_build_fortress_confirmed(province: Province) -> void:
	world_visuals.province_selection.deselect_province()
	var action_build := ActionBuild.new(province.id)
	_action_input.apply_action(action_build)


func _on_recruitment_confirmed(province: Province, troop_amount: int) -> void:
	world_visuals.province_selection.deselect_province()
	var action_recruitment := ActionRecruitment.new(
			province.id, troop_amount, game.world.armies.new_unique_id()
	)
	_action_input.apply_action(action_recruitment)


func _on_army_movement_closed() -> void:
	world_visuals.province_selection.deselect_province()


# Temporary feature
func _on_load_requested() -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		chat.send_system_message("Only the server can load a game!")
		return
	
	chat.send_system_message("Loading the save file...")
	
	get_parent().load_game()


func _on_save_requested() -> void:
	chat.send_system_message("Saving the game...")
	
	# TODO bad code (don't use get_parent like that)
	# The player should be able to change the file path for save files
	var save_file_path: String = get_parent().SAVE_FILE_PATH
	
	var game_save := GameSave.new()
	game_save.save_game(game, save_file_path)
	
	if game_save.error:
		var error_message: String = "Saving failed: " + game_save.error_message
		push_error(error_message)
		chat.send_system_message(error_message)
		return
	
	chat.send_system_message("[b]Game saved[/b]")


func _on_exit_to_main_menu_requested() -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		chat.send_system_message("Only the server can exit to main menu!")
		return
	
	exited.emit()


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
