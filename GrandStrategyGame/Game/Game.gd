extends Node2D


@export var world_scene: PackedScene
@export var province_scene: PackedScene
@export var army_scene: PackedScene
@export var number_of_troops_scene: PackedScene

var game_state: GameState
var simulation: GameState
var deletion_queue: Array[Army]


func _ready() -> void:
	var world: Node = world_scene.instantiate()
	
	# Set the camera's limits
	var camera := $Camera2D as Camera2D
	var world_size_node := world.get_node("WorldSize") as Marker2D
	camera.limit_right = int(world_size_node.position.x)
	camera.limit_bottom = int(world_size_node.position.y)
	
	# Setup provinces
	var shapes: Node = world.get_node("Shapes")
	var links: Array = []
	var provinces: Array[Province] = []
	var number_of_provinces: int = shapes.get_child_count()
	for i in number_of_provinces:
		# Setup the province itself
		var province_instance := province_scene.instantiate() as Province
		var shape := shapes.get_child(i) as ProvinceTestData
		links.append(shape.links)
		province_instance.set_shape(shape.polygon)
		province_instance.position = shape.position
		provinces.append(province_instance)
		
		# Setup the armies component
		var armies := Armies.new()
		armies.name = "Armies"
		var army_host_node := shape.get_node("ArmyHost") as Marker2D
		armies.position_army_host = army_host_node.position + shape.position
		province_instance.add_component(armies)
		
		# Connect the signals
		province_instance.connect(
				"selected", Callable(self, "_on_province_selected")
		)
	
	# Setup links
	for i in number_of_provinces:
		provinces[i].links = []
		var number_of_links: int = links[i].size()
		for j in number_of_links:
			provinces[i].links.append(provinces[links[i][j] - 1])
		$Provinces.add_child(provinces[i])
	
	# Setup the game's scenario
	var scenario := world.get_node("Scenarios/Scenario1") as Scenario1
	game_state = scenario.generate_game_state()
	
	var countries: Array[Country] = game_state.new_countries()
	var you := $Players/You as PlayerHuman
	you.playing_country = country_with_key(
			countries,
			game_state.player_country(game_state.human_player())
	)
	($CanvasLayer/GameUI/Chat as Chat).system_message(
			"You are playing as " + you.playing_country.country_name
	)
	var ai_players: Array[PlayerAI] = new_ai_players(
			game_state.data().get_array("players"),
			countries
	)
	var number_of_countries: int = countries.size()
	for i in number_of_countries:
		if ai_players[i].playing_country != you.playing_country:
			$Players.add_child(ai_players[i])
		$Countries.add_child(countries[i])
	
	for i in number_of_provinces:
		var province_key: String = game_state.provinces().data()[i].key()
		provinces[i]._key = province_key
		
		# Owner
		var owner_key: String = game_state.province_owner(province_key).data
		if owner_key != "-1":
			provinces[i].set_owner_country(
					country_with_key(countries, owner_key)
			)
		
		# Armies
		var armies_node := provinces[i].get_node("Armies") as Armies
		var armies: Array[Army] = (
				game_state.new_province_armies(province_key, army_scene)
		)
		var number_of_armies: int = armies.size()
		for j in number_of_armies:
			var army_key: String = (
					game_state.armies(province_key).data()[j].key()
			)
			
			armies[j].owner_country = country_with_key(
					countries,
					String(game_state.army_owner(province_key, army_key).data)
			)
			armies[j].troop_count = game_state.army_troop_count(
					province_key,
					army_key
			).data
			armies_node.add_army(armies[j])
		
		# Populations
		var population: int = game_state.province_population(province_key).data
		var population_node := Population.new(population)
		population_node.name = "Population"
		provinces[i].add_component(population_node)
	
	simulation = game_state.duplicate()


func _on_game_over(country: Country) -> void:
	var game_over_node := $CanvasLayer/GameUI/GameOverScreen as GameOver
	game_over_node.show()
	game_over_node.set_text(country.country_name + " wins!")


func _on_province_selected(province: Province) -> void:
	var player_country: Country = ($Players/You as PlayerHuman).playing_country
	var provinces_node := $Provinces as Provinces
	if provinces_node.a_province_is_selected():
		var selected_province: Province = provinces_node.selected_province
		var selected_armies := selected_province.get_node("Armies") as Armies
		if selected_armies.country_has_active_army(player_country):
			var army: Army = selected_armies.get_active_armies_of(player_country)[0]
			if selected_armies.army_can_be_moved_to(army, province):
				# Show interface for selecting a number of troops
				var troop_ui := number_of_troops_scene.instantiate() as RecruitUI
				troop_ui.name = "RecruitUI"
				troop_ui.setup(army, selected_province, province)
				troop_ui.connect(
						"cancelled",
						Callable(self, "_on_recruit_cancelled")
				)
				troop_ui.connect(
						"move_troops",
						Callable(self, "new_action_army_movement")
				)
				$CanvasLayer.add_child(troop_ui)
				return
	provinces_node.select_province(province)
	
	var armies_node := province.get_node("Armies") as Armies
	if armies_node.country_has_active_army(player_country):
		province.show_neighbours(2)
	else:
		province.show_neighbours(3)


func _on_background_clicked() -> void:
	unselect_province()


func _on_recruit_cancelled() -> void:
	unselect_province()


func _on_chat_requested_province_info() -> void:
	var provinces_node := $Provinces as Provinces
	var chat_node := $CanvasLayer/GameUI/Chat as Chat
	
	if not provinces_node.a_province_is_selected():
		chat_node.system_message("No province selected.")
		return
	
	var selected_province: Province = provinces_node.selected_province
	var population_node := selected_province.get_node("Population") as Population
	var population_count: int = population_node.population_count
	chat_node.system_message("Population count: " + str(population_count))


func country_with_key(countries: Array[Country], key: String) -> Country:
	for country in countries:
		if country.key() == key:
			return country
	return null


func new_ai_players(
		players_data: GameStateArray,
		countries: Array[Country]
) -> Array[PlayerAI]:
	var output: Array[PlayerAI] = []
	var players_data_array: Array[GameStateData] = players_data.data()
	for player_data in players_data_array:
		var player_data_array := player_data as GameStateArray
		var new_player: PlayerAI = new_ai_player(
				players_data,
				player_data.key()
		)
		var playing_country_key := String(
				player_data_array.get_string("playing_country").data
		)
		new_player.playing_country = (
				country_with_key(countries, playing_country_key)
		)
		new_player._key = player_data.key()
		output.append(new_player)
	return output


func new_ai_player(
		players_data: GameStateArray,
		player_key: String
) -> PlayerAI:
	var player_data: GameStateArray = players_data.get_array(player_key)
	var ai_data: GameStateArray = player_data.get_array("ai")
	var ai_class_name := String(ai_data.get_string("class_name").data)
	match ai_class_name:
		"TestAI1":
			return TestAI1.new()
	return null # Shouldn't happen


func unselect_province() -> void:
	($Provinces as Provinces).unselect_province()


func new_action_army_movement(
		army: Army,
		number_of_troops: int,
		source: Province,
		destination: Province
) -> void:
	unselect_province()
	
	var rules_node := $Rules as Rules
	var actions_node: Node = $Players/You/Actions
	
	var local_simulation: GameState = simulation.duplicate()
	var actions: Array[Action] = []
	var moving_army_key: String = army.key()
	
	# Split the army into two if needed
	if army.troop_count > number_of_troops:
		var new_army_key: String = (
				local_simulation.armies(source.key()).new_unique_key()
		)
		var action_split := ActionArmySplit.new(
				source.key(),
				army.key(),
				[army.troop_count - number_of_troops, number_of_troops],
				[new_army_key]
		)
		if not rules_node.action_is_legal(local_simulation, action_split):
			return
		actions.append(action_split)
		rules_node.connect_action(action_split)
		action_split.apply_to(local_simulation)
		
		moving_army_key = new_army_key
	
	var moving_army_new_key: String = (
			local_simulation.armies(destination.key()).new_unique_key()
	)
	var action_move := ActionArmyMovement.new(
			source.key(),
			moving_army_key,
			destination.key(),
			moving_army_new_key
	)
	if not rules_node.action_is_legal(local_simulation, action_move):
		return
	actions.append(action_move)
	rules_node.connect_action(action_move)
	action_move.apply_to(local_simulation)
	
	# Everything was okay, so now we can submit the actions
	simulation = local_simulation
	for action in actions:
		deletion_queue.append_array(
				action.update_visuals($Provinces as Provinces)
		)
		actions_node.add_child(action)
	
	# Play the movement animation
	var source_armies_node := source.get_node("Armies") as Armies
	var destination_armies_node := destination.get_node("Armies") as Armies
	var moving_army: Army = (
			destination_armies_node.army_with_key(moving_army_new_key)
	)
	var source_position: Vector2 = (
			source_armies_node.position_army_host - destination.position
	)
	var target_position: Vector2 = (
			destination_armies_node.position_army_host
			- destination_armies_node.global_position
	)
	moving_army.play_movement_to(source_position, target_position)


func end_turn() -> void:
	#print("************************************ End of turn ****************************************")
	var provinces_node := $Provinces as Provinces
	var provinces: Array[Province] = provinces_node.get_provinces()
	var rules_node := $Rules as Rules
	var players: Array[Node] = $Players.get_children()
	for player in players:
		var actions: Array[Action]
		if player is PlayerAI:
			# Have the AI play their moves
			actions = (player as PlayerAI).play(game_state.duplicate())
		else:
			actions = (player as Player).get_actions()
		
		# Process every player's actions
		for action in actions:
			if not player is PlayerHuman:
				rules_node.connect_action(action)
			if rules_node.action_is_legal(game_state, action):
				action.apply_to(game_state)
				if not player is PlayerHuman:
					deletion_queue.append_array(
							action.update_visuals(provinces_node)
					)
			action.queue_free()
		
		# Merge armies
		for province in provinces:
			merge_armies(game_state.armies(province.key()).data())
			(province.get_node("Armies") as Armies).merge_armies()
		
		# Remove the simulated armies from play
		for army in deletion_queue:
			army.queue_free()
		deletion_queue.clear()
		
		#print("--- End of player's turn")
	
	var current_turn: GameStateInt = game_state.data().get_int("turn")
	current_turn.data += 1
	rules_node.start_of_turn(game_state)
	
	simulation = game_state.duplicate()


func merge_armies(armies: Array[GameStateData]) -> void:
	var i: int = 0
	while i < armies.size():
		var army_i := armies[i] as GameStateArray
		for j in range(i + 1, armies.size()):
			var army_j := armies[j] as GameStateArray
			
			var owner_i: String = army_i.get_string("owner").data
			var owner_j: String = army_j.get_string("owner").data
			if owner_i == owner_j:
				armies.remove_at(i)
				i -= 1
				var troop_count_i: int = army_i.get_int("troop_count").data
				army_j.get_int("troop_count").data += troop_count_i
				break
		i += 1
