class_name GameState
extends Node


signal game_over(winner: Country)
signal province_selected(province: Province)

# Nodes
var rules: Rules
var countries: Countries
var players: Players
var world: GameWorld
var turn: GameTurn


func _on_new_turn() -> void:
	_check_percentage_winner()


func _on_game_over() -> void:
	# Get how many provinces each country has
	var ownership: Array = _province_count_per_country()
	
	# Find which player has the most provinces
	var winning_player_index: int = 0
	var number_of_players: int = ownership.size()
	for i in number_of_players:
		if ownership[i][1] > ownership[winning_player_index][1]:
			winning_player_index = i
	
	var winning_country: Country = ownership[winning_player_index][0]
	
	game_over.emit(winning_country)


func setup_turn(starting_turn: int = 1) -> void:
	const turn_scene: PackedScene = (
			preload("res://scenes/game_turn/no_turn_limit.tscn")
	)
	turn = turn_scene.instantiate() as GameTurn
	turn._turn = starting_turn
	turn.connect("game_over", Callable(self, "_on_game_over"))
	add_child(turn)


func connect_to_provinces(callable: Callable) -> void:
	world.connect_to_provinces(callable)


func copy() -> GameState:
	var builder := GameStateFromJSON.new(as_JSON())
	builder.build()
	return builder.game_state


func as_JSON() -> Dictionary:
	return {
		"rules": rules.as_JSON(),
		"countries": countries.as_JSON(),
		"players": players.as_JSON(),
		"world": world.as_JSON(),
		"turn": turn.as_JSON(),
	}


func _check_percentage_winner() -> void:
	var percentage_to_win: float = 70.0
	
	# Get how many provinces each country has
	var ownership: Array = _province_count_per_country()
	
	# Declare a winner if there is one
	var number_of_provinces: int = world.provinces.get_provinces().size()
	for o in ownership:
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
