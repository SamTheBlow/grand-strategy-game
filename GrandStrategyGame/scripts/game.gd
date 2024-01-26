class_name Game
extends Node


signal game_ended()

var _game_mediator: GameMediator

# The true, actual game state
var _game_state: GameState

# A simulation of the game state (this is what the player sees)
var _simulation: GameState

var _your_id: int

# TODO Temporary
var _global_attacker_efficiency: float = 1.0
var _global_defender_efficiency: float = 1.0

@onready var chat := %Chat as Chat


func _ready() -> void:
	chat.system_message(
			"You are playing as " + _game_state.players
			.player_from_id(_your_id).playing_country.country_name
	)


func _on_game_over(country: Country) -> void:
	var game_over_node := %GameOverPopup as GameOver
	game_over_node.show()
	game_over_node.set_text(country.country_name + " wins!")


func _on_province_selected(province: Province) -> void:
	var your_country: Country = (
			_simulation.countries.country_from_id(_your_id)
	)
	var provinces_node: Provinces = _simulation.world.provinces
	if provinces_node.selected_province:
		var selected_province: Province = provinces_node.selected_province
		var selected_armies: Armies = selected_province.armies
		if selected_armies.country_has_active_army(your_country):
			var army: Army = selected_armies.get_active_armies_of(your_country)[0]
			if selected_armies.army_can_be_moved_to(army, province):
				_new_popup_number_of_troops(army, selected_province, province)
				return
	provinces_node.select_province(province)
	
	var armies_node: Armies = province.armies
	if armies_node.country_has_active_army(your_country):
		province.show_neighbours(2)
	else:
		province.show_neighbours(3)


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
	
	var error: int = (
			GameSaveJSON.new(save_file_path).save_state(_game_state)
	)
	
	if error != OK:
		var error_message: String = "Failed to save the game"
		push_error(error_message)
		chat.system_message(error_message)
		return
	
	chat.new_message("[b]Game state saved[/b]")


func _on_exit_to_main_menu_requested() -> void:
	game_ended.emit()


func _on_chat_requested_province_info() -> void:
	var selected_province_simulation: Province = (
			_simulation.world.provinces.selected_province
	)
	if not selected_province_simulation:
		chat.system_message("No province selected.")
		return
	
	var selected_province_id: int = selected_province_simulation.id
	var selected_province: Province = (
			_game_state.world.provinces.province_from_id(selected_province_id)
	)
	var population_size: int = selected_province.population.population_size
	chat.system_message("Population size: " + str(population_size))


func _on_chat_rules_requested() -> void:
	var population_growth: String = "no"
	if _game_state.rules.population_growth:
		population_growth = "yes"
	
	var fortresses: String = "no"
	if _game_state.rules.fortresses:
		fortresses = "yes"
	
	var turn_limit: String = "none"
	if _game_state.rules.turn_limit_enabled:
		turn_limit = str(_game_state.rules.turn_limit) + " turns"
	
	chat.system_message_multiline([
		"This game's rules:",
		"-> Population growth: " + population_growth,
		"-> Fortresses: " + fortresses,
		"-> Turn limit: " + turn_limit,
	])


func _on_modifiers_requested(
		modifiers: Array[Modifier],
		context: ModifierContext
) -> void:
	match context.context():
		"attacker_efficiency":
			modifiers.append(ModifierMultiplier.new(
					"Base Modifier",
					"Attackers all have this modifier by default.",
					_global_attacker_efficiency
			))
		"defender_efficiency":
			modifiers.append(ModifierMultiplier.new(
					"Base Modifier",
					"Defenders all have this modifier by default.",
					_global_defender_efficiency
			))


func init() -> void:
	_game_mediator = GameMediator.new(self)
	
	_game_mediator.modifier_mediator().modifiers_requested.connect(
			_on_modifiers_requested
	)


## Returns true if it succeeded, otherwise false.
func load_from_path(local_path: String) -> bool:
	var loaded_game_state: GameState = (
			GameSaveJSON.new(local_path).load_state(_game_mediator)
	)
	if not loaded_game_state:
		return false
	
	var random_player: int = randi() % loaded_game_state.players.players.size()
	load_game_state(loaded_game_state, random_player)
	return true


func load_game_state(game_state: GameState, your_id: int) -> void:
	_game_state = game_state
	_game_state._game_mediator = _game_mediator
	_your_id = your_id
	
	# TODO bad code, shouldn't be here
	var camera := $Camera as Camera2D
	camera.limit_left = _game_state.world.limits.limit_left()
	camera.limit_top = _game_state.world.limits.limit_top()
	camera.limit_right = _game_state.world.limits.limit_right()
	camera.limit_bottom = _game_state.world.limits.limit_bottom()
	
	# TODO this shouldn't be here either
	# Find the province to move the camera to and move the camera there
	var playing_country: Country = _game_state.players.player_from_id(your_id).playing_country
	var target_province: Province
	for province in _game_state.world.provinces.get_provinces():
		if (
				province.has_owner_country()
				and province.owner_country() == playing_country
		):
			target_province = province
			break
	if target_province:
		camera.position = target_province.armies.position_army_host
	
	_game_state.connect_to_provinces(_on_province_selected)
	_game_state.game_over.connect(_on_game_over)
	_simulation = game_state.copy()
	
	# TODO bad code DRY
	_simulation.connect_to_provinces(_on_province_selected)
	
	$WorldLayer.add_child(_simulation)


## Temporary function
func load_from_scenario(scenario: Scenario1, rules: GameRules) -> void:
	var game_state: GameState = (
			scenario.generate_game_state(_game_mediator, rules)
	)
	var your_id: int = scenario.human_player
	
	_global_attacker_efficiency = rules.global_attacker_efficiency
	_global_defender_efficiency = rules.global_defender_efficiency
	
	load_game_state(game_state, your_id)


func deselect_province() -> void:
	_simulation.world.provinces.deselect_province()


func new_action_army_movement(
		army: Army,
		number_of_troops: int,
		source_province: Province,
		destination_province: Province
) -> void:
	deselect_province()
	
	var you: Player = _simulation.players.player_from_id(_your_id)
	var moving_army_id: int = army.id
	
	# Split the army into two if needed
	var army_size: int = army.army_size.current_size()
	if army_size > number_of_troops:
		var new_army_id: int = (
				_simulation.world.provinces
				.province_from_id(source_province.id)
				.armies.new_unique_army_id()
		)
		var action_split := ActionArmySplit.new(
				source_province.id,
				army.id,
				[army_size - number_of_troops, number_of_troops],
				[new_army_id]
		)
		action_split.apply_to(_game_mediator, _simulation, true)
		you.add_action(action_split)
		
		moving_army_id = new_army_id
	
	var moving_army_new_id: int = (
			_simulation.world.provinces
			.province_from_id(destination_province.id)
			.armies.new_unique_army_id()
	)
	var action_move := ActionArmyMovement.new(
			source_province.id,
			moving_army_id,
			destination_province.id,
			moving_army_new_id
	)
	action_move.apply_to(_game_mediator, _simulation, true)
	you.add_action(action_move)


func end_turn() -> void:
	#print("********** End of turn **********")
	
	# Always play the human's turn first
	_play_player_turn(_simulation.players.player_from_id(_your_id))
	# Then play the other players' turn
	for player in _simulation.players.players:
		if player.id == _your_id:
			continue
		_play_player_turn(player)
	
	_game_state.propagate_call("_on_new_turn")
	
	# Update the visible game state
	$WorldLayer.remove_child(_simulation)
	_simulation = _game_state.copy()
	
	# TODO bad code DRY
	_simulation.connect_to_provinces(_on_province_selected)
	
	$WorldLayer.add_child(_simulation)


func _play_player_turn(player: Player) -> void:
	# Have the AI play its moves
	if player.id != _your_id:
		(player as PlayerAI).play(_game_state.copy())
	
	# Process the player's actions
	var actions: Array[Action] = (player as Player).actions
	for action in actions:
		action.apply_to(_game_mediator, _game_state, false)
	
	# Merge armies
	for province in _game_state.world.provinces.get_provinces():
		province.armies.merge_armies()
	
	#print("--- End of player's turn")


## Create and display an interface for selecting a number of troops
func _new_popup_number_of_troops(
	army: Army,
	source_province: Province,
	destination_province: Province
) -> void:
	var troop_ui: TroopUI = (TroopUI.new_popup(
			army, source_province, destination_province,
			preload("res://scenes/troop_ui.tscn")
	))
	troop_ui.name = "RecruitUI"
	troop_ui.cancelled.connect(_on_recruit_cancelled)
	troop_ui.army_movement_requested.connect(new_action_army_movement)
	$UILayer.add_child(troop_ui)
