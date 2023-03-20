class_name RuleFortress
extends Rule


func _ready():
	listen_to = [["Combat", "battle_started", "_on_battle_started"]]


func _on_attack(attack: Attack):
	var fortress := attack.province.get_node("Fortress") as Fortress
	fortress._on_battle_started(attack)
