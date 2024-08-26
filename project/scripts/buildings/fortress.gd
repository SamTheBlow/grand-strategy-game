class_name Fortress
extends Building
## Currently, a fortress is a building that provides extra defense
## to any [Army] located in the [Province] the fortress is in.
## The fortress may be (and currently is) visible on the world map.
## There may only be one fortress per province,
## although, this currently isn't enforced.


var _province: Province


## Utility function that does all the setup work.
## It's recommended to use this when creating a new fortress.
static func new_fortress(game: Game, province: Province) -> Fortress:
	var fortress := Fortress.new()
	fortress._province = province
	game.add_modifier_provider(fortress)
	return fortress


## Provides the defense bonus to the defender when a battle occurs
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
