class_name Fortress
extends Node2D


var _game_mediator: GameMediator

var _province: Province


static func new_fortress(
		scene: PackedScene,
		game_mediator: GameMediator,
		input_position: Vector2
) -> Fortress:
	var fortress := scene.instantiate() as Fortress
	fortress.name = "Fortress"
	fortress._game_mediator = game_mediator
	fortress.position = input_position + Vector2(80.0, 56.0)
	
	game_mediator.modifier_mediator().modifiers_requested.connect(
			fortress._on_modifiers_requested
	)
	
	return fortress


func _on_modifiers_requested(
		modifiers: Array[Modifier],
		context: ModifierContext
) -> void:
	match context.context():
		"attacker_efficiency":
			# Check if defender is on same province as this fortress
			var defender: Army = context.info("defending_army")
			if _province == defender.province():
				# New modifier
				modifiers.append(ModifierMultiplier.new(
						"Fortress",
						"The fortress makes it harder to deal damage.",
						0.5
				))
