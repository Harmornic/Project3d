extends CharacterBody3D
class_name Enemy

signal reached_player

@export var max_spotting_distance := 5000
@export var speed := 9

var _current_speed := 0.0

@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var animation_player: AnimationPlayer = %EnemyModel/AnimationPlayer
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var _eye: Node3D = %Eye
@onready var _eye_ray_cast: RayCast3D = %EyeRayCast

# เรียกตอนเริ่มเกม
func _ready() -> void:
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

	# เชื่อมสัญญาณ Area3D (KillZone)
	$KillZone.body_entered.connect(_on_body_entered)

# เมื่อ Player ชนกับ KillZone
func _on_body_entered(body: Node) -> void:
	print("KillZone touched: ", body.name)
	if body.name == "Player" or body.name == "player":
		print(">>> PLAYER DETECTED! <<<")
		call_deferred("_go_to_game_over")

func _go_to_game_over() -> void:
	get_tree().change_scene_to_file("res://game_over/game_over.tscn")

# อัปเดตทุกเฟรม
func _physics_process(_delta: float) -> void:
	# Enemy ตรวจเห็น Player → วิ่งตาม
	if is_player_in_view():
		travel_to_position(player.global_position, speed, true)

	# ถ้าไม่มีทางเดิน ให้หยุด
	if navigation_agent.is_navigation_finished():
		animation_player.play("Idle", 0.2)
		return

	# หมุนหน้าไปทางที่กำลังจะไป
	var next_path_position := navigation_agent.get_next_path_position()
	var where_to_look := next_path_position
	where_to_look.y = global_position.y
	if not where_to_look.is_equal_approx(global_position):
		look_at(where_to_look)

	# เดินไปข้างหน้า
	var direction := next_path_position - global_position
	direction.y = 0.0
	direction = direction.normalized()
	velocity = direction * _current_speed
	move_and_slide()

# เดินไปยังตำแหน่งที่กำหนด
func travel_to_position(wanted_position: Vector3, speed: float, play_run_anim := false) -> void:
	navigation_agent.target_position = wanted_position
	_current_speed = speed
	
	if play_run_anim:
		animation_player.play("Run", 0.2)
	else:
		animation_player.play("Walk", 0.2)

# ตรวจว่ามองเห็น Player หรือไม่
func is_player_in_view() -> bool:
	var vec_to_player := player.global_position - global_position

	if vec_to_player.length() > max_spotting_distance:
		return false

	return not is_line_of_sight_broken()

# ตรวจว่ามีสิ่งกีดขวางไหม (RayCast)
# ตรวจว่ามีสิ่งกีดขวางไหม (RayCast)
func is_line_of_sight_broken() -> bool:
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 1.5, 0),  # จุดเริ่ม ray (หัว enemy)
		player.global_position + Vector3(0, 1.5, 0)  # จุดจบ ray (หัว player)
	)
	query.exclude = [self]  # ไม่ตรวจชนตัวเอง
	query.collision_mask = 1  # ตรวจเฉพาะ layer 1 (พื้น/สิ่งกีดขวาง)
	
	var result = space_state.intersect_ray(query)
	
	# ถ้ามี object ขวางระหว่าง Enemy กับ Player
	if result.size() > 0 and result["collider"] != player:
		return true
	
	return false
