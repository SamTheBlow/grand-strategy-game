class_name ArmyPreviewNode
extends Control

const _ARMY_VISUALS_SCENE := preload("uid://eso260jnknd4") as PackedScene


func setup(army: Army, playing_country: PlayingCountry) -> void:
	var visuals := _ARMY_VISUALS_SCENE.instantiate() as ArmyVisuals2D
	visuals.army = army
	visuals.playing_country = playing_country
	visuals.is_preview = true
	visuals.preview_container = self
	if is_node_ready():
		add_child(visuals)
	else:
		ready.connect(add_child.bind(visuals), ConnectFlags.CONNECT_ONE_SHOT)
