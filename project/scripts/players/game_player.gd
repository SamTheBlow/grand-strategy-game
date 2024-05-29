class_name GamePlayer
extends Node
## Class responsible for a game's player.
## This player can be either a human or an AI.
## The player may either control a [Country] or spectate.


signal human_status_changed(player: GamePlayer)
signal username_changed(new_username: String)

## All players have a unique id, for the purposes of
## saving/loading and networking. (You must ensure their unicity yourself)
var id: int

## Null means the player is spectating.
var playing_country: Country

## Note that if you are turning this player into a human, then
## you might want to set the player_human property before setting this one
var is_human: bool = false:
	set(value):
		is_human = value
		if not is_human:
			player_human = null
		human_status_changed.emit(self)

## This player's username. Allows you to give AI players a username.
## This property is automatically sync'd to a human [Player]'s username.
## If this property is set to an empty String, then it returns
## the playing country's name, or, if spectating, returns "Spectator".
var username: String = "":
	get:
		if username != "":
			return username
		elif is_spectating():
			return "Spectator"
		else:
			return playing_country.country_name
	set(value):
		if username == value:
			return
		
		username = value
		if is_human and player_human:
			player_human.custom_username = value
		else:
			_inform_clients_of_username_change()
		
		username_changed.emit(value)

## A reference to this human player's [Player] object.
## It is only relevant when [code]is_human[/code] is set to true.
## This can intentionally be null, even after everything is set up.
var player_human: Player:
	set(value):
		if player_human:
			player_human.username_changed.disconnect(_on_username_changed)
		
		if value:
			player_human = null
			username = value.username()
			value.username_changed.connect(_on_username_changed)
		
		player_human = value

# TODO this is ugly
## For loading purposes. -1 means it doesn't represent any human player.
var player_human_id: int = -1:
	get:
		if player_human:
			return player_human.id
		return player_human_id

## This player's AI.
## It may only be used when [code]is_human[/code] is set to false.
var player_ai := PlayerAI.new()


func is_spectating() -> bool:
	return playing_country == null


# TODO doesn't really belong here... at least make the function static
func ai_from_type(type: int) -> PlayerAI:
	match type:
		0:
			return PlayerAI.new()
		1:
			return TestAI1.new()
		2:
			return TestAI2.new()
		_:
			print_debug("Invalid AI type.")
			return null


## Returns the AI type as a number, for saving/loading.
func ai_type() -> int:
	if not player_ai:
		print_debug("Player AI is null.")
		return -1
	elif player_ai is TestAI1:
		return 1
	elif player_ai is TestAI2:
		return 2
	elif player_ai is PlayerAI:
		return 0
	else:
		print_debug("Unrecognized AI type.")
		return -1


static func is_valid_ai_type(type: int) -> bool:
	return type >= 0 and type <= 2


## For saving/loading purposes
func raw_data() -> Dictionary:
	var player_data: Dictionary = {}
	player_data["id"] = id
	if playing_country:
		player_data["playing_country_id"] = playing_country.id
	player_data["is_human"] = is_human
	player_data["username"] = username
	if is_human and player_human:
		player_data["human_id"] = player_human.id
	player_data["ai_type"] = ai_type()
	return player_data


#region Synchronize username
func _inform_clients_of_username_change() -> void:
	if not MultiplayerUtils.has_authority(multiplayer) or not is_inside_tree():
		return
	
	_receive_new_username.rpc(username)


@rpc("authority", "call_remote", "reliable")
func _receive_new_username(value: String) -> void:
	username = value
#endregion


func _on_username_changed(new_username: String) -> void:
	username = new_username
