class_name Game
extends Node


signal game_started()
signal game_ended()

@export_category("Scenes")
@export var army_scene: PackedScene
@export var fortress_scene: PackedScene
@export var province_scene: PackedScene
@export var world_2d_scene: PackedScene
@export var networking_setup_scene: PackedScene

@export_category("UI scenes")
@export var troop_ui_scene: PackedScene
@export var component_ui_scene: PackedScene
@export var player_turn_scene: PackedScene
@export var player_list_scene: PackedScene
@export var popup_scene: PackedScene
@export var army_movement_scene: PackedScene
@export var game_over_scene: PackedScene
@export var build_fortress_scene: PackedScene
@export var recruitment_scene: PackedScene

@export_category("Children")
@export var camera: CustomCamera2D
@export var game_ui: Control
@export var component_ui_root: Control
@export var top_bar: TopBar
@export var right_side: Node
@export var popups: Control

var rules: GameRules:
	set(value):
		rules = value
		_setup_global_modifiers()

var countries: Countries
var game_players: GamePlayers
var turn: GameTurn
var turn_limit: TurnLimit

## Keys are a modifier context (String); values are a Modifier.
## This property is setup automatically when loading in the game rules.
var global_modifiers: Dictionary = {}

## Reference to external node
var chat: Chat:
	get:
		if not chat:
			print_debug("Game's chat property is not initialized!")
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

## Child node
var component_ui: ComponentUI

var _modifier_request: ModifierRequest

var _chat_interface: ChatInterface:
	get:
		if not _chat_interface:
			_chat_interface = %ChatInterface as ChatInterface
		return _chat_interface

# It is only stored in memory because we need it to connect to chats
var _networking_interface: NetworkingInterface

# It is only stored in memory because we need it to connect to players
var _player_list: PlayerList

var _you: GamePlayer
var _game_over: bool = false


## Initialization to be done immediately after loading the game scene.
func init() -> void:
	_networking_interface = (
			networking_setup_scene.instantiate() as NetworkingInterface
	)
	_modifier_request = ModifierRequest.new(self)
	add_modifier_provider(self)


## Call this when you're ready to start the game loop.
func start() -> void:
	game_started.emit()
	turn.loop()


## Dependency injection.
func setup_players(players: Players) -> void:
	game_players.assign_lobby(players)
	
	# Create the player list
	_player_list = player_list_scene.instantiate() as PlayerList
	_player_list.players = players
	_player_list.game_turn = turn
	_player_list.use_networking_interface(_networking_interface)
	right_side.add_child(_player_list)


## For loading. The rules must be setup beforehand.
func setup_turn(starting_turn: int = 1, playing_player_index: int = 0) -> void:
	turn = GameTurn.new()
	turn.game = self
	turn._turn = starting_turn
	turn._playing_player_index = playing_player_index
	
	if rules.turn_limit_enabled:
		turn_limit = TurnLimit.new()
		turn_limit.final_turn = rules.turn_limit
		turn_limit.game_over.connect(_on_game_over)
	
	turn.turn_changed.connect(_on_new_turn)


## Creates a new instance of Game with the exact same state as this game.
func copy() -> Game:
	var game_to_json := GameToJSON.new()
	game_to_json.convert_game(self)
	if game_to_json.error:
		print_debug(
				"Error converting game to JSON: "
				+ game_to_json.error_message
		)
	var game_from_json := GameFromJSON.new()
	# TODO bad code, don't use get_parent. Find a better way to get the scene
	game_from_json.load_game(game_to_json.result, get_parent().game_scene)
	if game_from_json.error:
		print_debug(
				"Error loading game from JSON: "
				+ game_from_json.error_message
		)
	return game_from_json.result


func modifiers(context: ModifierContext) -> ModifierList:
	return _modifier_request.modifiers(context)


func add_modifier_provider(object: Object) -> void:
	_modifier_request.add_provider(object)


func deselect_province() -> void:
	world.provinces.deselect_province()


func new_action_army_movement(
		army: Army,
		number_of_troops: int,
		destination_province: Province
) -> void:
	var moving_army_id: int = army.id
	
	# Split the army into two if needed
	var army_size: int = army.army_size.current_size()
	if army_size > number_of_troops:
		var new_army_id: int = world.armies.new_unique_army_id()
		var action_split := ActionArmySplit.new(
				army.id,
				[army_size - number_of_troops, number_of_troops],
				[new_army_id]
		)
		action_split.apply_to(self, _you)
		
		moving_army_id = new_army_id
	
	var action_move := ActionArmyMovement.new(
			moving_army_id, destination_province.id
	)
	action_move.apply_to(self, _you)


func set_human_player(player: GamePlayer) -> void:
	if _you and _you == player:
		return
	
	if _you:
		_you.human_status_changed.disconnect(_on_your_human_status_changed)
	
	_you = player
	_you.human_status_changed.connect(_on_your_human_status_changed)
	top_bar.set_playing_country(_you.playing_country)
	_move_camera_to_country(_you.playing_country)
	
	print("It's now the turn of ", player.username)
	print("Player turn order:")
	for game_player in game_players.list():
		print(game_player.username, "" if game_player.is_human else " (AI)", " (spectator)" if game_player.is_spectating() else "")
	
	# Only announce a new player's turn when there is more than 1 human player
	if game_players.number_of_playing_humans() < 2:
		return
	
	var player_turn := (
			player_turn_scene.instantiate() as PlayerTurnAnnouncement
	)
	player_turn.set_player_username(player.username)
	game_ui.add_child(player_turn)


func _setup_global_modifiers() -> void:
	global_modifiers = {}
	if rules.global_attacker_efficiency != 1.0:
		global_modifiers["attacker_efficiency"] = (
				ModifierMultiplier.new(
						"Base Modifier",
						"Attackers all have this modifier by default.",
						rules.global_attacker_efficiency
				)
		)
	if rules.global_defender_efficiency != 1.0:
		global_modifiers["defender_efficiency"] = (
				ModifierMultiplier.new(
						"Base Modifier",
						"Defenders all have this modifier by default.",
						rules.global_defender_efficiency
				)
		)


## Moves the camera to one of the country's controlled provinces
## If that country doesn't control any province, this method does nothing
func _move_camera_to_country(country: Country) -> void:
	var target_province: Province
	for province in world.provinces.get_provinces():
		if (
				province.has_owner_country()
				and province.owner_country() == country
		):
			target_province = province
			break
	if target_province:
		camera.move_to(target_province.position_army_host)


func _winning_country() -> Country:
	# Get how many provinces each country has
	var ownership: Array = _province_count_per_country()
	
	# Find which player has the most provinces
	var winning_player_index: int = 0
	var number_of_players: int = ownership.size()
	for i in number_of_players:
		if ownership[i][1] > ownership[winning_player_index][1]:
			winning_player_index = i
	
	return ownership[winning_player_index][0]


func _add_army_movement_popup(army: Army, destination: Province) -> void:
	var army_movement_popup := (
			army_movement_scene.instantiate() as ArmyMovementPopup
	)
	army_movement_popup.init(army, destination)
	army_movement_popup.confirmed.connect(new_action_army_movement)
	army_movement_popup.tree_exited.connect(_on_army_movement_closed)
	_add_popup(army_movement_popup)


func _add_popup(contents: Node) -> void:
	var popup := popup_scene.instantiate() as GamePopup
	popup.setup_contents(contents)
	popups.add_child(popup)


func _check_percentage_winner() -> void:
	var percentage_to_win: float = 70.0
	
	# Get how many provinces each country has
	var ownership: Array = _province_count_per_country()
	
	# Declare a winner if there is one
	var number_of_provinces: int = world.provinces.get_provinces().size()
	for o: Array in ownership:
		if float(o[1]) / number_of_provinces >= percentage_to_win * 0.01:
			_on_game_over()
			break


func _province_count_per_country() -> Array:
	var output: Array = []
	
	for province in world.provinces.get_provinces():
		if not province.has_owner_country():
			continue
		
		# Find the country on our list
		var index: int = -1
		var output_size: int = output.size()
		for i in output_size:
			if output[i][0] == province.owner_country():
				index = i
				break
		
		# It isn't on our list. Add it
		if index == -1:
			output.append([province.owner_country(), 1])
		# It is on our list. Increase its number of owned provinces
		else:
			output[index][1] += 1
	
	return output


func _outline_province_links(
		province: Province, target_outline: bool = false
) -> void:
	var outline_type := ProvinceShapePolygon2D.OutlineType.NEIGHBOR
	if target_outline:
		outline_type = ProvinceShapePolygon2D.OutlineType.NEIGHBOR_TARGET
	province.show_neighbors(outline_type)


func _on_new_turn(_turn: int) -> void:
	_check_percentage_winner()


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


func _on_province_clicked(province: Province) -> void:
	var provinces_node: Provinces = world.provinces
	
	if not MultiplayerUtils.has_gameplay_authority(multiplayer, _you):
		provinces_node.select_province(province)
		_outline_province_links(province)
		return
	
	var your_country: Country = _you.playing_country
	if provinces_node.selected_province:
		var selected_province: Province = provinces_node.selected_province
		var active_armies: Array[Army] = world.armies.active_armies(
				your_country, selected_province
		)
		if active_armies.size() > 0:
			var army: Army = active_armies[0]
			
			# If this isn't here, the game crashes. I don't know why.
			# (This line does nothing, it's just to prevent a crash)
			# TODO figure it out
			army.battle.attacking_army = army
			
			if army.can_move_to(province):
				_add_army_movement_popup(army, province)
				return
	provinces_node.select_province(province)
	
	var active_armies_: Array[Army] = world.armies.active_armies(
			your_country, province
	)
	_outline_province_links(province, active_armies_.size() > 0)


func _on_province_selected() -> void:
	component_ui = component_ui_scene.instantiate() as ComponentUI
	component_ui.init(world.provinces.selected_province, _you)
	turn.player_changed.connect(component_ui._on_turn_player_changed)
	component_ui.button_pressed.connect(_on_component_ui_button_pressed)
	component_ui_root.add_child(component_ui)


func _on_province_deselected() -> void:
	component_ui_root.remove_child(component_ui)
	component_ui.queue_free()


func _on_component_ui_button_pressed(button_id: int) -> void:
	match button_id:
		0:
			# Build fortress
			var build_popup := (
					build_fortress_scene.instantiate() as BuildFortressPopup
			)
			build_popup.init(
					world.provinces.selected_province,
					rules.fortress_price
			)
			build_popup.confirmed.connect(_on_build_fortress_confirmed)
			_add_popup(build_popup)
		1:
			# Recruitment
			var army_recruitment_limit := ArmyRecruitmentLimit.new(
					_you.playing_country,
					world.provinces.selected_province
			)
			var recruitment_popup := (
					recruitment_scene.instantiate() as RecruitmentPopup
			)
			recruitment_popup.init(
					world.provinces.selected_province,
					rules.minimum_army_size,
					army_recruitment_limit.maximum()
			)
			recruitment_popup.confirmed.connect(_on_recruitment_confirmed)
			_add_popup(recruitment_popup)


func _on_end_turn_pressed() -> void:
	turn.end_turn()


func _on_build_fortress_confirmed(province: Province) -> void:
	deselect_province()
	var action_build := ActionBuild.new(province.id)
	action_build.apply_to(self, _you)


func _on_recruitment_confirmed(province: Province, troop_amount: int) -> void:
	deselect_province()
	var action_recruitment := ActionRecruitment.new(
			province.id, troop_amount, world.armies.new_unique_army_id()
	)
	action_recruitment.apply_to(self, _you)


func _on_army_movement_closed() -> void:
	deselect_province()


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
		lines.append("-> " + rule_name + ": " + str(rules.get(rule_name)))
	chat.send_system_message_multiline(lines)


func _on_modifiers_requested(
		modifiers_: Array[Modifier],
		context: ModifierContext
) -> void:
	if global_modifiers.has(context.context()):
		modifiers_.append(global_modifiers[context.context()])


func _on_your_human_status_changed(_player: Player) -> void:
	# If you're no longer playing as a human,
	# skip this player's turn and continue playing
	if not _you.is_human:
		turn.end_turn()
