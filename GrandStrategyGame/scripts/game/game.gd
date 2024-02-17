class_name Game
extends Node


signal game_ended()

@export var army_scene: PackedScene
@export var fortress_scene: PackedScene
@export var province_scene: PackedScene
@export var world_2d_scene: PackedScene

@export var troop_ui_scene: PackedScene
@export var component_ui_scene: PackedScene
@export var popup_scene: PackedScene
@export var army_movement_scene: PackedScene
@export var game_over_scene: PackedScene
@export var build_fortress_scene: PackedScene
@export var recruitment_scene: PackedScene

@export var component_ui_root: Control
@export var top_bar: TopBar
@export var chat: Chat
@export var popups: Control

var _modifier_request: ModifierRequest

var rules: GameRules
var countries: Countries
var players: Players

# References to children nodes
var world: GameWorld
var turn: GameTurn
var component_ui: ComponentUI

var _you: Player
var _game_over: bool = false

## Keys are a modifier context (String); values are a Modifier
var global_modifiers: Dictionary = {}


func _on_new_turn() -> void:
	_check_percentage_winner()


func _on_game_over() -> void:
	if _game_over:
		return
	
	var winning_country: Country = end_game()
	
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
	var your_country: Country = _you.playing_country
	var provinces_node: Provinces = world.provinces
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
	if active_armies_.size() > 0:
		province.show_neighbors(
				ProvinceShapePolygon2D.OutlineType.NEIGHBOR_TARGET
		)
	else:
		province.show_neighbors(ProvinceShapePolygon2D.OutlineType.NEIGHBOR)


func _on_province_selected() -> void:
	component_ui = component_ui_scene.instantiate() as ComponentUI
	component_ui.init(world.provinces.selected_province, _you.playing_country)
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
	get_parent().load_game()
	
	chat.send_system_message("Failed to load the game")


func _on_save_requested() -> void:
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


## Initialization 1. To be done immediately after loading the game scene.
func init1() -> void:
	_modifier_request = ModifierRequest.new(self)
	add_modifier_provider(self)


## Initialization 2. To be done after everything is loaded.
func init2() -> void:
	# Setup global modifiers
	global_modifiers = {}
	global_modifiers["attacker_efficiency"] = (
			ModifierMultiplier.new(
					"Base Modifier",
					"Attackers all have this modifier by default.",
					rules.global_attacker_efficiency
			)
	)
	global_modifiers["defender_efficiency"] = (
			ModifierMultiplier.new(
					"Base Modifier",
					"Defenders all have this modifier by default.",
					rules.global_defender_efficiency
			)
	)
	
	# TODO bad code, shouldn't be here
	var camera := $Camera as CustomCamera2D
	camera.limits = world.limits
	
	# TODO this shouldn't be here either
	# Find the province to move the camera to and move the camera there
	var target_province: Province
	for province in world.provinces.get_provinces():
		if (
				province.has_owner_country()
				and province.owner_country() == _you.playing_country
		):
			target_province = province
			break
	if target_province:
		camera.position = target_province.position_army_host
	
	$WorldLayer.add_child(world)
	top_bar.init(self, _you.playing_country)


## For loading. The rules must be setup beforehand.
func setup_turn(starting_turn: int = 1) -> void:
	turn = GameTurn.new()
	turn.name = "Turn"
	turn._turn = starting_turn
	
	if rules.turn_limit_enabled:
		var turn_limit := TurnLimit.new()
		turn_limit.name = "TurnLimit"
		turn_limit._final_turn = rules.turn_limit
		turn_limit.game_over.connect(_on_game_over)
		
		turn.add_child(turn_limit)
	
	add_child(turn)


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


func end_turn() -> void:
	#print("********** End of turn **********")
	
	# End your turn
	_end_player_turn()
	
	# Play all other players' turn
	for player in players.players:
		if player == _you:
			continue
		_play_player_turn(player)
	
	propagate_call("_on_new_turn")


## Returns the winner.
func end_game() -> Country:
	# Get how many provinces each country has
	var ownership: Array = _province_count_per_country()
	
	# Find which player has the most provinces
	var winning_player_index: int = 0
	var number_of_players: int = ownership.size()
	for i in number_of_players:
		if ownership[i][1] > ownership[winning_player_index][1]:
			winning_player_index = i
	
	var winning_country: Country = ownership[winning_player_index][0]
	return winning_country


func _play_player_turn(player: Player) -> void:
	# Have the AI play its moves
	(player as PlayerAI).play(self)
	
	# Process the player's actions
	var actions: Array[Action] = (player as Player).actions
	for action in actions:
		action.apply_to(self, player)
	
	_end_player_turn()


func _end_player_turn() -> void:
	# Merge armies
	for province in world.provinces.get_provinces():
		world.armies.merge_armies(province)
	
	# Refresh the army visuals
	for army in world.armies.armies:
		army.refresh_visuals()
	
	for province in world.provinces.get_provinces():
		# Update province ownership
		ProvinceNewOwner.new().update_province_owner(province)
		
		# For debugging, check if there's more than one army on any province
		if world.armies.armies_in_province(province).size() > 1:
			print_debug(
					"At the end of a player's turn, found more than "
					+ "one army in province (ID: " + str(province.id) + ")."
			)
	
	#print("--- End of player's turn")


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
