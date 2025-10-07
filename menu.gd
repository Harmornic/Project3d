extends Node2D


func _ready():
	$Control/AudioStreamPlayer2D.play()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://WORLD2.tscn")



func _on_button_2_pressed() -> void:
	get_tree().quit()
