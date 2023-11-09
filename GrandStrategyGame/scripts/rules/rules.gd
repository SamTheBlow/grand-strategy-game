class_name Rules
extends Node


@export var fortresses: bool = false


static func build() -> Rules:
	var game_rules := Rules.new()
	game_rules.name = "Rules"
	return game_rules


func as_json() -> Dictionary:
	return {
		"fortress": fortresses,
	}
