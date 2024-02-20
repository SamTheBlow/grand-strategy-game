class_name PlayerTurnAnnouncement
extends Control
## The interface that appears when
## it becomes a different person's turn to play.


@export var animation_player: AnimationPlayer
@export var label: Label


func _ready() -> void:
	animation_player.play("new_animation")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if get_parent():
		get_parent().remove_child(self)
	queue_free()


func set_player_username(username: String) -> void:
	label.text = "It's " + username + "'s turn"
