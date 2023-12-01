class_name GameState
extends Node


signal game_over(winner: Country)
signal province_selected(province: Province)

# Nodes
var countries: Countries
var players: Players
var world: GameWorld
var turn: GameTurn

# Other data
var rules: GameRules


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


## The rules must be setup beforehand!
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


func connect_to_provinces(callable: Callable) -> void:
	world.connect_to_provinces(callable)


func copy() -> GameState:
	var builder := GameStateFromJSON.new(as_json())
	builder.build()
	return builder.game_state


func as_json() -> Dictionary:
	return {
		"countries": countries.as_json(),
		"players": players.as_json(),
		"world": world.as_json(),
		"turn": turn.as_json(),
		"rules": rules.as_json(),
	}


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
