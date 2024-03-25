class_name Fortress
extends Building


var game: Game

var _province: Province


static func new_fortress(game_: Game, province: Province) -> Fortress:
	var fortress := Fortress.new()
	fortress.name = "Fortress"
	fortress.game = game_
	fortress._province = province
	game_.add_modifier_provider(fortress)
	return fortress


func add_visuals() -> void:
	var visuals: Node = game.fortress_scene.instantiate()
	
	if visuals.has_method("set_position"):
		visuals.set_position(
				_province.position_army_host + Vector2(80.0, 56.0)
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
		"defender_efficiency":
			# Check if defender is on same province as this fortress
			var defender: Army = context.info("defending_army")
			if _province == defender.province():
				# New modifier
				modifiers.append(ModifierMultiplier.new(
						"Fortress",
						"The fortress makes it easier to defend.",
						2.0
				))
