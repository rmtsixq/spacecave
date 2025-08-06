extends CharacterBody2D

@export var jump_force = -200
@export var gravity = 980
@export var max_fall_speed = 600
@export var move_speed = 200
@export var max_thrust_force = -600

var is_jumping = false
var can_jump = true
var current_thrust_force = 0
var thrust_time = 0
var max_thrust_time = 2.0

var health = 3
var health_ui = []
var damage_cooldown = 0.0
var damage_cooldown_time = 0.5

func _ready():
	create_health_ui()

func _physics_process(delta):
	apply_gravity(delta)
	handle_input(delta)
	move_and_slide()
	
	damage_cooldown -= delta
	check_collision()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > max_fall_speed:
			velocity.y = max_fall_speed

func handle_input(delta):
	velocity.x = move_speed
	
	if Input.is_action_pressed("ui_accept"):
		thrust(delta)
	elif Input.is_action_just_released("ui_accept"):
		stop_thrust()

func thrust(delta):
	thrust_time += delta
	if thrust_time > max_thrust_time:
		thrust_time = max_thrust_time
	
	current_thrust_force = jump_force - (thrust_time * 200)
	if current_thrust_force < max_thrust_force:
		current_thrust_force = max_thrust_force
	
	velocity.y = current_thrust_force
	is_jumping = true

func stop_thrust():
	is_jumping = false
	thrust_time = 0
	current_thrust_force = 0

func create_health_ui():
	for i in range(3):
		var health_rect = ColorRect.new()
		health_rect.color = Color.RED
		health_rect.size = Vector2(20, 20)
		health_rect.position = Vector2(10 + i * 25, 10)
		add_child(health_rect)
		health_ui.append(health_rect)

func check_collision():
	if (is_on_wall() or is_on_ceiling()) and damage_cooldown <= 0:
		take_damage()
		damage_cooldown = damage_cooldown_time

func take_damage():
	health -= 1
	if health >= 0 and health < health_ui.size():
		health_ui[health].queue_free()
	
	if health <= 0:
		restart_game()

func restart_game():
	var current_scene = get_tree().current_scene
	var scene_path = current_scene.scene_file_path
	var new_scene = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene



func _on_floor_detected():
	can_jump = true
	is_jumping = false
