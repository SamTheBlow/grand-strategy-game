class_name GamePopup
extends Control
## Class responsible for popups that may appear during a game.
##
## You set up this class by setting the "contents_node"
## property with a node of your choice.
##
## The given node may be any node. The node will be added to the scene
## and its contents will appear inside the popup.
##
## The popup may have buttons at the bottom.
## Those buttons will always close the popup when pressed,
## but you may also add custom behavior to each of them.
##
## To add buttons to the bottom of the popup,
## give your node a method "buttons" that returns an array of strings.
## Each string is the name of the button: it will appear on the button.
## If no buttons are provided, the popup will have a "OK" button by default.
##
## To know when a button is pressed,
## give your node a method "_on_button_pressed" that takes one int argument.
## That argument is the button's index in the list of buttons that you gave.


var contents_node: Node

@onready var _contents_root := %Contents as Control
@onready var _popup_buttons := %Buttons as PopupButtons


func _ready() -> void:
	if contents_node == null:
		return
	
	_contents_root.add_child(contents_node)
	_add_content_buttons()


func _add_content_buttons() -> void:
	var button_names: Array[String] = ["OK"]
	
	if contents_node != null and contents_node.has_method("buttons"):
		button_names = contents_node.call("buttons")
	
	_popup_buttons.setup_buttons(button_names)
	_popup_buttons.pressed.connect(_on_button_pressed)
	
	_connect_content_to_buttons()


func _connect_content_to_buttons() -> void:
	if not contents_node.has_method("_on_button_pressed"):
		return
	
	_popup_buttons.pressed.connect(
			Callable(contents_node, "_on_button_pressed")
	)


func _on_button_pressed(_button_id: int) -> void:
	queue_free()
