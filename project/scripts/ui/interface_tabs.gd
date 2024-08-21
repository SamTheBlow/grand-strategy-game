extends Control
## When one of the given buttons is pressed,
## shows their corresponding node and hides all the other ones.


## The buttons to listen to. The buttons will be automatically
## assigned an id and their signals will be automatically connected.
@export var buttons: Array[IdButton]

## Make sure they are in the same order as the buttons in the buttons array!
@export var corresponding_ui: Array[Control]

## The tab that will be shown by default
@export var default_option: int = 0


func _ready() -> void:
	for i in buttons.size():
		buttons[i].id = i
		buttons[i].id_pressed.connect(_on_button_pressed)
	
	_on_button_pressed(default_option)


func _on_button_pressed(id: int) -> void:
	for i in corresponding_ui.size():
		if i == id:
			corresponding_ui[i].show()
		else:
			corresponding_ui[i].hide()
