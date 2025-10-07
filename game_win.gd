extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _on_button_pressed() -> void:
	get_tree().quit()
