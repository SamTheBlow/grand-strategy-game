extends Control
## A simple interface for hosting and joining servers.


@export var port: int = 31400

## When hosting, this is the maximum number of users
## allowed on the server at any time, [b]excluding the host[/b].
@export var max_clients: int = 2

## If set to true, this interface will go invisible 
## if the user successfully connects to a server.
## It will be visible again if the user disconnects from the server.
@export var autohide: bool = true

@onready var _ip_address_node := %IPAddress as LineEdit
@onready var _feedback := %ServerFeedback as Label
@onready var _feedback_animation := %FeedbackAnimation as AnimationPlayer


func _ready() -> void:
	_feedback.text = ""
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_host_pressed() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error: int = peer.create_server(port, max_clients)
	
	_handle_error(error, false)
	
	if error == OK:
		multiplayer.set_multiplayer_peer(peer)
		
		if autohide:
			hide()
		
		# This doesn't get emitted automatically because you're the server
		multiplayer.connected_to_server.emit()


func _on_join_pressed() -> void:
	var ip_address: String = _ip_address_node.text
	if ip_address == "":
		ip_address = "localhost"
	
	var peer := ENetMultiplayerPeer.new()
	var error: int = peer.create_client(ip_address, port)
	
	_handle_error(error, true)
	
	if error == OK:
		multiplayer.set_multiplayer_peer(peer)
		
		if autohide:
			hide()


func _on_server_disconnected() -> void:
	# Yellow text
	_feedback.modulate = Color(1, 0.9, 0.6, 1)
	_feedback.text = "Disconnected from server"
	_feedback_animation.play("animate_feedback")
	if autohide:
		show()


func _handle_error(error: int, joining: bool) -> void:
	# Red text
	_feedback.modulate = Color(1, 0.5, 0.5, 1)
	
	match error:
		ERR_ALREADY_IN_USE:
			_feedback.text = "Error: already connected to a server"
		ERR_CANT_CREATE:
			if joining:
				_feedback.text = "Error: failed to join server"
			else:
				_feedback.text = "Error: failed to create server"
		ERR_CANT_RESOLVE:
			_feedback.text = "Error: can't resolve (wrong IP address?)"
		OK:
			# Green text
			_feedback.modulate = Color(0.5, 1, 0.5, 1)
			
			if joining:
				_feedback.text = "Joined server"
			else:
				_feedback.text = "Hosting server"
		_:
			_feedback.text = "An unexpected error occured"
	
	_feedback_animation.play("animate_feedback")
