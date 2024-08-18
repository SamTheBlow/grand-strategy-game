class_name Game
extends Node
## The game.
## There are so many things to setup, there are entire classes
## dedicated to loading the game (see [LoadGame], [GameFromJSON]...).
## Setting up this node manually yourself is not recommended.
##
## This is definitely the most messy script in the entire project.


signal game_started()
signal game_ended()

@export_group("Scenes")
@export var army_scene: PackedScene
@export var fortress_scene: PackedScene
@export var province_scene: PackedScene
@export var world_2d_scene: PackedScene
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
@export var action_sync: ActionSynchronizer
@export var camera: CustomCamera2D
@export var game_ui: Control
@export var component_ui_root: Control
@export var popups: Control

@export_group("Resources")
## Defines the outcome of a [Battle].
@export var battle: Battle

## Must setup before the game starts.
## You are not meant to edit the rules once they are set.
var rules: GameRules:
	set(value):
		rules = value
		_setup_global_modifiers()

## Must setup before the game starts.
## All of the [Country] objects used in this game should be listed in here.
var countries := Countries.new()

## Must setup before the game starts.
## This list must not be empty.
var game_players: GamePlayers:
	set(value):
		if game_players:
			remove_child(game_players)
		game_players = value
		game_players.name = "GamePlayers"
		add_child(game_players)

## Must setup before the game starts.
var turn: GameTurn:
	set(value):
		turn = value
		_turn_order_list.game_turn = turn
		_auto_end_turn = AutoEndTurn.new(self)

## You don't need to initialize this, especially if you don't want
## the game to have a turn limit. However, if you do want to use it,
## some setup needs to be done: see [method Game.setup_turn].
var turn_limit: TurnLimit

## You don't need to initialize this, especially if you don't want
## the game to have a province control goal. If you do want to use it,
## some setup needs to be done: see [method Game.setup_turn].
var province_control_goal: ProvinceControlGoal

## Keys are a modifier context (String); values are a Modifier.
## This property is setup automatically when loading in the game rules.
var global_modifiers: Dictionary = {}

## Reference to external node
var chat: Chat:
	get:
		if not chat:
			push_warning("Game's chat property is not initialized!")
			chat = Chat.new()
		return chat
	set(value):
		chat = value
		
		_chat_interface.chat_data = chat.chat_data
		chat.connect_chat_interface(_chat_interface)
		
		_networking_interface.message_sent.connect(
			chat._on_networking_interface_message_sent
		)
		chat.save_requested.connect(_on_save_requested)
		chat.load_requested.connect(_on_load_requested)
		chat.exit_to_main_menu_requested.connect(
				_on_exit_to_main_menu_requested
		)
		chat.rules_requested.connect(_on_chat_rules_requested)

## Child node
var world: GameWorld:
	set(value):
		if world and world.get_parent():
			world.get_parent().remove_child(world)
		
		world = value
		
		if world is GameWorld2D:
			camera.world_limits = (world as GameWorld2D).limits
		$WorldLayer.add_child(world)

var rng := RandomNumberGenerator.new()

## Child node: the interface that appears when you select a [Province]
var component_ui: ComponentUI:
	set(value):
		if component_ui != null:
			component_ui_root.remove_child(component_ui)
			component_ui.queue_free()
		component_ui = value

## Automatically setup when calling [method Game.init].
## See also: [method Game.modifiers]
var _modifier_request: ModifierRequest

## It is stored in memory only because we need it to connect to the [Chat].
var _networking_interface: NetworkingInterface

## The user is allowed to continue playing after the game "ends".
var _game_over: bool = false

## Child node
var _chat_interface: ChatInterface:
	get:
		if not _chat_interface:
			_chat_interface = %ChatInterface as ChatInterface
		return _chat_interface

## Child node
var _lobby_list: PlayerList:
	get:
		if not _lobby_list:
			_lobby_list = %PlayerList as PlayerList
		return _lobby_list

## Child node
var _turn_order_list: TurnOrderList:
	get:
		if not _turn_order_list:
			_turn_order_list = %TurnOrderList as TurnOrderList
		return _turn_order_list

var _auto_end_turn: AutoEndTurn

var _military_access_loss_behavior: MilitaryAccessLossBehavior
var _diplomacy_relationship_auto_changes: DiplomacyRelationshipAutoChanges


## Initialization to be done immediately after loading the game scene.
func init() -> void:
	_networking_interface = (
			networking_setup_scene.instantiate() as NetworkingInterface
	)
	_lobby_list.use_networking_interface(_networking_interface)
	_modifier_request = ModifierRequest.new(self)
	add_modifier_provider(self)


## Call this when you're ready to start the game loop.
func start() -> void:
	# TODO this shouldn't be here in start, but, where should it go?
	_military_access_loss_behavior = MilitaryAccessLossBehavior.new(self)
	_diplomacy_relationship_auto_changes = (
			DiplomacyRelationshipAutoChanges.new(self)
	)
	
	rules.lock()
	game_started.emit()
	turn.loop()


## Dependency injection.
## Using this is not mandatory, but it is necessary to inject [Players]
## if you want to use online multiplayer features.
func setup_players(players: Players) -> void:
	game_players.assign_lobby(players)
	
	#print("After. ", Engine.get_main_loop().get_multiplayer().get_unique_id())
	#print("GAME PLAYERS")
	#for game_player in game_players.list():
	#	print(
	#			game_player.username, "; ",
	#			game_player.is_human, "; ", game_player.player_human_id
	#	)
	#print("PLAYERS")
	#for player in players.list():
	#	print(player.username(), "; ", player.id)
	
	_lobby_list.players = players
	_turn_order_list.players = game_players


## Initializes the [member Game.turn] and the [member Game.turn_limit].
## The [member Game.rules] must be setup beforehand.
func setup_turn(starting_turn: int = 1, playing_player_index: int = 0) -> void:
	turn = GameTurn.new()
	turn.game = self
	turn._turn = starting_turn
	turn._playing_player_index = playing_player_index
	
	if rules.turn_limit_enabled.value:
		turn_limit = TurnLimit.new()
		turn_limit.final_turn = rules.turn_limit.value
		turn.turn_changed.connect(turn_limit._on_new_turn)
		turn_limit.game_over.connect(_on_game_over)
	
	province_control_goal = ProvinceControlGoal.new()
	province_control_goal.game = self
	turn.turn_changed.connect(province_control_goal._on_new_turn)
	province_control_goal.game_over.connect(_on_game_over)


## Returns a [ModifierList] relevant to the given [ModifierContext].
func modifiers(context: ModifierContext) -> ModifierList:
	return _modifier_request.modifiers(context)


## Call this to register any object to the [ModifierRequest] system.
## For example, a [Fortress] provides a [Modifier]
## that boosts an [Army]'s defense during a [Battle].
## So any new instance of [Fortress] must be registered using this function.
func add_modifier_provider(object: Object) -> void:
	_modifier_request.add_provider(object)


# TODO this shouldn't be here..?
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
		var new_army_id: int = world.armies.new_unique_id()
		var action_split := ActionArmySplit.new(
				army.id,
				[army_size - number_of_troops, number_of_troops],
				[new_army_id]
		)
		action_sync.apply_action(action_split)
		
		moving_army_id = new_army_id
	
	var action_move := ActionArmyMovement.new(
			moving_army_id, destination_province.id
	)
	action_sync.apply_action(action_move)


## Builds this game's global [Modifier]s according to the [GameRules].
## Call this when the [GameRules] are set.
func _setup_global_modifiers() -> void:
	global_modifiers = {}
	if rules.global_attacker_efficiency.value != 1.0:
		global_modifiers["attacker_efficiency"] = (
				ModifierMultiplier.new(
						"Base Modifier",
						"Attackers all have this modifier by default.",
						rules.global_attacker_efficiency.value
				)
		)
	if rules.global_defender_efficiency.value != 1.0:
		global_modifiers["defender_efficiency"] = (
				ModifierMultiplier.new(
						"Base Modifier",
						"Defenders all have this modifier by default.",
						rules.global_defender_efficiency.value
				)
		)


## Used to determine the winner when the game ends.
func _winning_country() -> Country:
	# Get how many provinces each country has
	var ownership: Array = world.provinces.province_count_per_country()
	
	# Find which player has the most provinces
	var winning_player_index: int = 0
	var number_of_players: int = ownership.size()
	for i in number_of_players:
		if ownership[i][1] > ownership[winning_player_index][1]:
			winning_player_index = i
	
	return ownership[winning_player_index][0]


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


func _on_game_over() -> void:
	if _game_over:
		return
	
	var winning_country: Country = _winning_country()
	
	var game_over_popup := game_over_scene.instantiate() as GameOverPopup
	game_over_popup.init(winning_country)
	_add_popup(game_over_popup)
	
	chat.send_global_message(
			"The game is over! The winner is "
			+ str(winning_country.country_name) + "."
	)
	chat.send_global_message("You can continue playing if you want.")
	_game_over = true


func _on_province_unhandled_mouse_event(
		event: InputEventMouse, province: Province
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
	
	var provinces_node: Provinces = world.provinces
	var you: GamePlayer = turn.playing_player()
	
	# You're not the one playing? Select province and return
	if not MultiplayerUtils.has_gameplay_authority(multiplayer, you):
		provinces_node.select_province(province)
		return
	
	# If applicable, open the army movement popup
	var your_country: Country = you.playing_country
	if provinces_node.selected_province:
		var selected_province: Province = provinces_node.selected_province
		var active_armies: Array[Army] = world.armies.active_armies(
				your_country, selected_province
		)
		if active_armies.size() > 0:
			var army: Army = active_armies[0]
			if army.can_move_to(province):
				_add_army_movement_popup(army, province)
				return
	
	provinces_node.select_province(province)


func _on_province_selected() -> void:
	component_ui = component_ui_scene.instantiate() as ComponentUI
	component_ui.province = world.provinces.selected_province
	turn.player_changed.connect(component_ui._on_turn_player_changed)
	component_ui.button_pressed.connect(_on_component_ui_button_pressed)
	component_ui_root.add_child(component_ui)


func _on_province_deselected() -> void:
	component_ui = null


func _on_component_ui_button_pressed(button_id: int) -> void:
	match button_id:
		0:
			# Build fortress
			var build_popup := (
					build_fortress_scene.instantiate() as BuildFortressPopup
			)
			build_popup.province = world.provinces.selected_province
			build_popup.confirmed.connect(_on_build_fortress_confirmed)
			_add_popup(build_popup)
		1:
			# Recruitment
			var army_recruitment_limits := ArmyRecruitmentLimits.new(
					turn.playing_player().playing_country,
					world.provinces.selected_province
			)
			var recruitment_popup := (
					recruitment_scene.instantiate() as RecruitmentPopup
			)
			recruitment_popup.province = world.provinces.selected_province
			recruitment_popup.min_amount = army_recruitment_limits.minimum()
			recruitment_popup.max_amount = army_recruitment_limits.maximum()
			recruitment_popup.confirmed.connect(_on_recruitment_confirmed)
			_add_popup(recruitment_popup)


func _on_end_turn_pressed() -> void:
	action_sync.apply_action(ActionEndTurn.new())


func _on_build_fortress_confirmed(province: Province) -> void:
	world.provinces.deselect_province()
	var action_build := ActionBuild.new(province.id)
	action_sync.apply_action(action_build)


func _on_recruitment_confirmed(province: Province, troop_amount: int) -> void:
	world.provinces.deselect_province()
	var action_recruitment := ActionRecruitment.new(
			province.id, troop_amount, world.armies.new_unique_id()
	)
	action_sync.apply_action(action_recruitment)


func _on_army_movement_closed() -> void:
	world.provinces.deselect_province()


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
	game_save.save_game(self, save_file_path)
	
	if game_save.error:
		push_error("Saving failed: " + game_save.error_message)
		chat.send_system_message("Saving failed: " + game_save.error_message)
		return
	
	chat.send_system_message("[b]Game saved[/b]")


func _on_exit_to_main_menu_requested() -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		chat.send_system_message("Only the server can exit to main menu!")
		return
	
	game_ended.emit()


func _on_chat_rules_requested() -> void:
	var lines: Array[String] = []
	lines.append("This game's rules:")
	for rule_name in GameRules.RULE_NAMES:
		var rule_data: Variant = rules.rule_with_name(rule_name).get_data()
		lines.append("-> " + rule_name + ": " + str(rule_data))
	chat.send_system_message_multiline(lines)


## This object is itself a provider for the [ModifierRequest] system.
## It provides the game's global [Modifier]s.
func _on_modifiers_requested(
		modifiers_: Array[Modifier],
		context: ModifierContext
) -> void:
	if global_modifiers.has(context.context()):
		modifiers_.append(global_modifiers[context.context()])


func _on_country_button_pressed(country: Country) -> void:
	var country_info: Control = (
			country_info_scene.instantiate() as CountryInfoPopup
	)
	country_info.game = self
	country_info.country = country
	_add_popup(country_info)


func _on_diplomacy_action_pressed(
		diplomacy_action: DiplomacyAction,
		recipient_country: Country
) -> void:
	# TODO this check shouldn't be here...
	if (
			not MultiplayerUtils
			.has_gameplay_authority(multiplayer, turn.playing_player())
	):
		push_warning(
				"Tried to perform a diplomatic action, but"
				+ " the user does not have gameplay authority!"
		)
		return
	
	action_sync.apply_action(ActionDiplomacy.new(
			diplomacy_action.id(), recipient_country.id
	))


func _on_notification_pressed(game_notification: GameNotification) -> void:
	var notification_info: Control = (
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
			.has_gameplay_authority(multiplayer, turn.playing_player())
	):
		push_warning(
				"Tried to handle a game notification, but"
				+ " the user does not have gameplay authority!"
		)
		return
	
	action_sync.apply_action(ActionHandleNotification.new(
			game_notification.id, outcome_index
	))
