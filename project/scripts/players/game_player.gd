class_name GamePlayer
extends Node
## Class responsible for a game's player.
## This player can be either a human or an AI.
## The player may either control a [Country] or spectate.


signal human_status_changed(player: GamePlayer)

## All players have a unique id to tell them apart.
## (You must ensure this yourself)
var id: int

## If the player is spectating, returns [code]null[/code].
var playing_country: Country

var is_human: bool = false:
	set(value):
		is_human = value
		human_status_changed.emit(self)

## This player's username. Allows you to give AI players a username.
## If this player is human, then it instead returns
## the player's username taken from the [Player] object.
## If this property is set to an empty String, then it returns
## the playing country's name, or, if spectating, returns "Spectator".
var username: String = "":
	get:
		if is_human and player_human:
			return player_human.username()
		elif username != "":
			return username
		else:
			if is_spectating():
				return "Spectator"
			else:
				return playing_country.country_name

## A reference to this human player's [Player] object.
## It is only relevant when [code]is_human[/code] is set to true.
## WARNING This can be [code]null[/code], even after everything is set up.
var player_human: Player

## This player's AI.
## It may only be used when [code]is_human[/code] is set to false.
var player_ai := PlayerAI.new()


func is_spectating() -> bool:
	return playing_country == null


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


## Returns the AI type. Relevant for saving/loading.
func ai_type() -> int:
	if not player_ai:
		print_debug("Player AI is null.")
		return -1
	elif player_ai is PlayerAI:
		return 0
	elif player_ai is TestAI1:
		return 1
	elif player_ai is TestAI2:
		return 2
	else:
		print_debug("Unrecognized AI type.")
		return -1


static func is_valid_ai_type(type: int) -> bool:
	return type >= 0 and type <= 2
