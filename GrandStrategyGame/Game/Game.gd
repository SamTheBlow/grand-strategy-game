extends Node2D

@export var world_scene:PackedScene
@export var province_scene:PackedScene
@export var number_of_troops_scene:PackedScene

var current_turn:int = 1

func _ready():
	var world = world_scene.instantiate()
	var scenario = world.get_node("Scenarios/Scenario1")
	
	# Set the camera's limits
	$Camera2D.limit_right = world.get_node("WorldSize").position.x
	$Camera2D.limit_bottom = world.get_node("WorldSize").position.y
	
	var countries = scenario.get_playable_countries()
	$Players/You.playing_country = countries[0]
	for country in countries:
		if country != $Players/You.playing_country:
			var country_ai = scenario.get_new_ai_for(country)
			country_ai.init(country)
			$Players.add_child(country_ai)
		$Countries.add_child(country)
	
	# Setup provinces
	var shapes = world.get_node("Shapes")
	var links = []
	var provinces = []
	var province_count = shapes.get_child_count()
	for i in province_count:
		# Setup the province itself
		var province_instance = province_scene.instantiate()
		var shape = shapes.get_child(i)
		links.append(shape.links)
		province_instance.set_shape(shape.polygon)
		province_instance.position = shape.position
		provinces.append(province_instance)
		# Setup the armies component
		var armies = Armies.new()
		armies.name = "Armies"
		armies.position_army_host = shape.get_node("ArmyHost").global_position
		province_instance.add_component(armies)
		# Connect the signals
		province_instance.connect("selected", Callable(self, "_on_province_selected"))
	# Setup links
	for i in province_count:
		provinces[i].links = []
		var number_of_links = links[i].size()
		for j in number_of_links:
			provinces[i].links.append(provinces[links[i][j] - 1])
		$Provinces.add_child(provinces[i])
	
	# Setup the game's scenario
	scenario.populate_provinces($Provinces.get_children(), countries)

func _on_game_over(country:Country):
	var game_over_node:GameOver = $CanvasLayer/GameUI/GameOverScreen
	game_over_node.show()
	game_over_node.set_text(country.country_name + " wins!")

func _on_province_selected(province:Province):
	var player_country = $Players/You.playing_country
	if $Provinces.a_province_is_selected():
		var selected_province = $Provinces.selected_province
		var selected_armies = selected_province.get_node("Armies")
		if selected_armies.country_has_active_army(player_country):
			var army = selected_armies.get_active_armies_of(player_country)[0]
			if selected_armies.army_can_be_moved_to(army, province):
				# Show interface for selecting a number of troops
				var troop_ui = number_of_troops_scene.instantiate()
				troop_ui.name = "RecruitUI"
				troop_ui.setup(army, selected_province, province)
				troop_ui.connect("cancelled", Callable(self, "_on_recruit_cancelled"))
				troop_ui.connect("move_troops", Callable(self, "move_troops"))
				$CanvasLayer.add_child(troop_ui)
				return
	$Provinces.select_province(province)
	if province.get_node("Armies").country_has_active_army(player_country):
		province.show_neighbours(2)
	else:
		province.show_neighbours(3)

func _on_background_clicked():
	unselect_province()

func unselect_province():
	$Provinces.unselect_province()

func _on_recruit_cancelled():
	unselect_province()

func move_troops(army:Army, number_of_troops:int, source:Province, destination:Province):
	unselect_province()
	
	var action_move = ActionArmyMovement.new(army, destination)
	if $Rules.action_is_legal(action_move) == false:
		return
	
	# Split the army into two if needed
	var action_split = ActionArmySplit.new(army, source, [number_of_troops, army.troop_count - number_of_troops])
	if army.troop_count > number_of_troops:
		if $Rules.action_is_legal(action_split) == false:
			return
		$Players/You/Actions.add_child(action_split)
	
	$Players/You/Actions.add_child(action_move)
	
	# Play the movement animation
	army.play_movement_to(army.position - army.global_position + destination.get_node("Armies").position_army_host)

func end_turn():
	var players = $Players.get_children()
	for player in players:
		# Have the AI play their moves
		if player is PlayerAI:
			player.play($Provinces.get_children())
		# Go through each player's actions
		var actions = player.get_actions()
		for action in actions:
			$Rules.connect_action(action)
			if $Rules.action_is_legal(action):
				action.play_action()
			else:
				action.queue_free()
	
	# Merge armies
	var provinces:Array[Province] = $Provinces.get_provinces()
	for province in provinces:
		province.get_node("Armies").merge_armies()
	
	current_turn += 1
	$Rules.start_of_turn(provinces, current_turn)

func _on_chat_requested_province_info():
	if not $Provinces.a_province_is_selected():
		$CanvasLayer/GameUI/Chat.system_message("No province selected.")
		return
	
	var selected_province = $Provinces.selected_province
	var population_count = selected_province.get_node("Population").population_count
	$CanvasLayer/GameUI/Chat.system_message("Population count: " + str(population_count))
