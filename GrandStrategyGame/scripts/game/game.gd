class_name Game
extends Node


signal game_ended()

var _modifier_request: ModifierRequest

var rules: GameRules
var countries: Countries
var players: Players

# References to children nodes
var world: GameWorld
var turn: GameTurn

var _your_id: int

## Keys are a modifier context (String); values are a Modifier
var global_modifiers: Dictionary = {}

@onready var chat := %Chat as Chat


func _ready() -> void:
	chat.system_message(
			"You are playing as "
			+ players.player_from_id(_your_id).playing_country.country_name
	)


func _on_new_turn() -> void:
	_check_percentage_winner()


func _on_game_over(country: Country) -> void:
	var game_over_node := %GameOverPopup as GameOver
	game_over_node.show()
	game_over_node.set_text(country.country_name + " wins!")


func _on_province_selected(province: Province) -> void:
	var your_country: Country = countries.country_from_id(_your_id)
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
				_new_popup_number_of_troops(army, province)
				return
	provinces_node.select_province(province)
	
	var active_armies_: Array[Army] = world.armies.active_armies(
			your_country, province
	)
	if active_armies_.size() > 0:
		province.show_neighbors(ProvinceShapePolygon2D.OutlineType.NEIGHBOR_TARGET)
	else:
		province.show_neighbors(ProvinceShapePolygon2D.OutlineType.NEIGHBOR)


func _on_recruit_cancelled() -> void:
	deselect_province()


# Temporary feature
func _on_load_requested() -> void:
	get_parent().load_game()
	
	chat.system_message("Failed to load the game")


func _on_save_requested() -> void:
	# TODO bad code (don't use get_parent like that)
	# The player should be able to change the file path for save files
	var save_file_path: String = get_parent().SAVE_FILE_PATH
	
	var game_save := GameSave.new()
	game_save.save_game(self, save_file_path)
	
	if game_save.error:
		push_error("Saving failed: " + game_save.error_message)
		chat.system_message("Saving failed: " + game_save.error_message)
		return
	
	chat.new_message("[b]Game saved[/b]")


func _on_exit_to_main_menu_requested() -> void:
	game_ended.emit()


func _on_chat_requested_province_info() -> void:
	var selected_province: Province = world.provinces.selected_province
	if not selected_province:
		chat.system_message("No province selected.")
		return
	
	var population_size: int = selected_province.population.population_size
	chat.system_message("Population size: " + str(population_size))


func _on_chat_rules_requested() -> void:
	var population_growth: String = "no"
	if rules.population_growth:
		population_growth = "yes"
	
	var fortresses: String = "no"
	if rules.fortresses:
		fortresses = "yes"
	
	var turn_limit: String = "none"
	if rules.turn_limit_enabled:
		turn_limit = str(rules.turn_limit) + " turns"
	
	var global_attacker_efficiency: String = (
		str(rules.global_attacker_efficiency)
	)
	var global_defender_efficiency: String = (
		str(rules.global_defender_efficiency)
	)
	
	chat.system_message_multiline([
		"This game's rules:",
		"-> Population growth: " + population_growth,
		"-> Fortresses: " + fortresses,
		"-> Turn limit: " + turn_limit,
		"-> Global attacker efficiency: " + global_attacker_efficiency,
		"-> Global defender efficiency: " + global_defender_efficiency,
	])


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
func init2(your_id: int) -> void:
	_your_id = your_id
	
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
	var camera := $Camera as Camera2D
	camera.limit_left = world.limits.limit_left()
	camera.limit_top = world.limits.limit_top()
	camera.limit_right = world.limits.limit_right()
	camera.limit_bottom = world.limits.limit_bottom()
	
	# TODO this shouldn't be here either
	# Find the province to move the camera to and move the camera there
	var playing_country: Country = players.player_from_id(your_id).playing_country
	var target_province: Province
	for province in world.provinces.get_provinces():
		if (
				province.has_owner_country()
				and province.owner_country() == playing_country
		):
			target_province = province
			break
	if target_province:
		camera.position = target_province.position_army_host
	
	$WorldLayer.add_child(world)


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
	game_from_json.load_game(game_to_json.result)
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
	deselect_province()
	
	var you: Player = players.player_from_id(_your_id)
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
		action_split.apply_to(self)
		you.add_action(action_split)
		
		moving_army_id = new_army_id
	
	var action_move := ActionArmyMovement.new(
			moving_army_id, destination_province.id
	)
	action_move.apply_to(self)
	you.add_action(action_move)


func end_turn() -> void:
	#print("********** End of turn **********")
	
	# Merge your armies
	for province in world.provinces.get_provinces():
		world.armies.merge_armies(province)
	
	# Play all other players' turn
	for player in players.players:
		if player.id == _your_id:
			continue
		_play_player_turn(player)
	
	propagate_call("_on_new_turn")


func end_game() -> void:
	# Get how many provinces each country has
	var ownership: Array = _province_count_per_country()
	
	# Find which player has the most provinces
	var winning_player_index: int = 0
	var number_of_players: int = ownership.size()
	for i in number_of_players:
		if ownership[i][1] > ownership[winning_player_index][1]:
			winning_player_index = i
	
	var winning_country: Country = ownership[winning_player_index][0]
	
	_on_game_over(winning_country)


func _play_player_turn(player: Player) -> void:
	# Have the AI play its moves
	if player.id != _your_id:
		(player as PlayerAI).play(copy())
	
	# Process the player's actions
	var actions: Array[Action] = (player as Player).actions
	for action in actions:
		action.apply_to(self)
	
	# Merge armies
	for province in world.provinces.get_provinces():
		world.armies.merge_armies(province)
	
	#print("--- End of player's turn")


## Create and display an interface for selecting a number of troops
func _new_popup_number_of_troops(
	army: Army,
	destination_province: Province
) -> void:
	var troop_ui: TroopUI = (TroopUI.new_popup(
			army,
			destination_province,
			preload("res://scenes/troop_ui.tscn")
	))
	troop_ui.name = "RecruitUI"
	troop_ui.cancelled.connect(_on_recruit_cancelled)
	troop_ui.army_movement_requested.connect(new_action_army_movement)
	$UILayer.add_child(troop_ui)


func _check_percentage_winner() -> void:
	var percentage_to_win: float = 70.0
	
	# Get how many provinces each country has
	var ownership: Array = _province_count_per_country()
	
	# Declare a winner if there is one
	var number_of_provinces: int = world.provinces.get_provinces().size()
	for o: Array in ownership:
		if float(o[1]) / number_of_provinces >= percentage_to_win * 0.01:
			end_game()
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
