extends Node3D

var score = 0

func add_score():
	score += 1
	print("Score:", score)

	# ถ้าเก็บครบ 7 เหรียญ
	if score >= 7:
		go_to_win_scene()

func go_to_win_scene():
	# เปลี่ยนไปยัง scene WIN
	get_tree().change_scene_to_file("res://game_win.tscn")
