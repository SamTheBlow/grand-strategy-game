extends Rule
class_name RuleFortress

func _ready():
	listen_to = [["Combat", "attack", "_on_attack"]]

func _on_attack(attack:Attack):
	attack.province.get_node("Fortress")._on_attack(attack)
