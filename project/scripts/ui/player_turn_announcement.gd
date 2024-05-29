class_name PlayerTurnAnnouncement
extends Control
## The interface that appears when it becomes
## a different player's turn to play.
## This interface automatically fades out and
## deletes itself from the scene tree after some time.
##
## To use, just add this node to the scene tree and
## don't forget to give it the player's username using set_player_username().


@export var animation_player: AnimationPlayer
@export var label: Label


func _ready() -> void:
	animation_player.play("new_animation")


func set_player_username(username: String) -> void:
	label.text = "It's " + username + "'s turn"


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if get_parent():
		get_parent().remove_child(self)
	queue_free()
