extends Node3D

func _ready():
	$AnimationPlayer2.play("Jumpscare")
	$AudioStreamPlayer3D.play()
	await $AnimationPlayer2.animation_finished
	get_tree().change_scene_to_file("res://game_over/game_over.tscn")
