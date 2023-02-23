extends Node2D

export (PackedScene) var world_data
export (PackedScene) var province_scene
export (PackedScene) var army_scene
export (PackedScene) var number_of_troops_scene

onready var player_country = $Countries/Country1

func _ready():
	$PlayerAI.playing_country = $Countries/Country2
	var _connect_error = $Rules/Rule.connect("game_over", self, "_on_game_over")
	
	# Setup provinces
	var world_data_instance = world_data.instance()
	var shapes = world_data_instance.get_node("Shapes")
	var army_positions = world_data_instance.get_node("Positions")
	var links = []
	var province = []
	var province_count = shapes.get_child_count()
	for i in province_count:
		var province_instance = province_scene.instance()
		var shape = shapes.get_child(i)
		links.append(shape.links)
		province_instance.position_army_host = army_positions.get_child(i).position
		province_instance.set_shape(shape.polygon)
		province_instance.position = shape.position
		province.append(province_instance)
	# Setup links
	for i in province_count:
		province[i].links = []
		var number_of_links = links[i].size()
		for j in number_of_links:
			province[i].links.append(province[links[i][j] - 1])
		$Provinces.add_child(province[i])
	
	# Give countries a province and some troops
	var number_of_players = 2
	var player = [$Countries/Country1, $Countries/Country2]
	var start_province = [$Provinces.get_child(4), $Provinces.get_child(9)]
	for i in number_of_players:
		start_province[i].set_owner_country(player[i])
		var army = army_scene.instance()
		army.owner_country = player[i]
		army.troop_count = 100
		start_province[i].add_troops(army)

func _process(_delta):
	if Input.is_action_just_pressed("mouse_left"):
		var mouse_position = get_viewport().get_mouse_position()
		var province_count = $Provinces.get_child_count()
		var selected_province = false
		for i in province_count:
			var province = $Provinces.get_child(i)
			var local_mouse_position = mouse_position - province.position
			if Geometry.is_point_in_polygon(local_mouse_position, province.get_shape()):
				select_province(province)
				selected_province = true
				break
		if selected_province == false:
			$Provinces.unselect_province()

func _on_game_over(country:Country):
	$CanvasLayer2/GameOverScreen.show()
	$CanvasLayer2/GameOverScreen/MarginContainer/VBoxContainer/Winner.text = country.country_name + " wins!"

#TODO this needs refactoring :)
func select_province(province:Province):
	if $Provinces.a_province_is_selected():
		var selected = $Provinces.selected_province
		if selected.army_can_be_moved_to(player_country, province):
			# Show interface for selecting a number of troops
			var troop_ui = number_of_troops_scene.instance()
			var army = selected.get_active_army(player_country)
			troop_ui.setup(army, province)
			troop_ui.connect("move_troops", self, "move_troops")
			$CanvasLayer.add_child(troop_ui)
			return
	$Provinces.select_province(province)
	if province.country_has_active_army(player_country):
		province.show_neighbours(2)
	else:
		province.show_neighbours(3)

func move_troops(army, number_of_troops, destination):
	# Add the army movement to the action queue
	var action_split = ActionArmySplit.new(army, [number_of_troops, army.troop_count - number_of_troops])
	$Actions.add_child(action_split)
	
	var action_move = ActionArmyMovement.new(army, destination)
	$Actions.add_child(action_move)
	
	# Play the movement animation
	army.play_movement_to(army.position - army.global_position + destination.position_army_host)
	
	$Provinces.unselect_province()

func end_turn():
	# Go through all of the countries' actions
	var actions = $Actions.get_children()
	for a in actions:
		a.play_action()
		look_for_battles()
	$PlayerAI.play($Provinces.get_children())
	
	var provinces = $Provinces.get_children()
	for p in provinces:
		# Merge armies
		p.merge_armies()
		# Determine province ownership
		var new_owner:Country = p.new_owner()
		if new_owner != null:
			p.set_owner_country(new_owner)
	
	$Rules/Rule._start_of_turn(provinces)

func look_for_battles():
	var provinces = $Provinces.get_children()
	for p in provinces:
		p.look_for_battles()
