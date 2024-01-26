class_name Fortress
extends Building


var _game_mediator: GameMediator

var _province: Province


static func new_fortress(
		game_mediator: GameMediator,
		province: Province
) -> Fortress:
	var fortress := Fortress.new()
	fortress.name = "Fortress"
	fortress._game_mediator = game_mediator
	fortress._province = province
	
	game_mediator.modifier_mediator().modifiers_requested.connect(
			fortress._on_modifiers_requested
	)
	
	return fortress


func add_visuals(visuals_scene: PackedScene) -> void:
	var visuals: Node = visuals_scene.instantiate()
	
	if visuals.has_method("set_position"):
		visuals.set_position(
				_province.armies.position_army_host + Vector2(80.0, 56.0)
		)
	
	add_child(visuals)


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


func as_json() -> Dictionary:
	return { "type": "fortress" }
