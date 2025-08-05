extends CharacterBody2D

# Balanced Physics Constants
const GRAVITY = 250.0  # Moderate gravity
const AIR_RESISTANCE = 0.99  # Good air resistance
const WATER_RESISTANCE = 0.95  # Water resistance for underwater sections
const MOVE_SPEED = 200.0  # Moderate movement speed
const MIN_THRUST_FORCE = 400.0   # Stronger minimum thrust
const MAX_THRUST_FORCE = 800.0   # Stronger maximum thrust
const THRUST_DELAY = 0.03        # Fast thrust response
const TILT_ANGLE = 25.0          # Moderate tilt
const TILT_DURATION = 0.2        # Fast tilt animation
const THRUST_RAMP_TIME = 0.2     # Fast power ramp
const MOMENTUM_DECAY = 0.99      # Good momentum preservation
const MAX_VELOCITY = 800.0       # Good max velocity
const MIN_VELOCITY = 15.0        # Minimum velocity threshold
const BOUNCE_FACTOR = 0.5        # Wall bounce factor
const FRICTION = 0.9              # Surface friction
const BUOYANCY = 0.2             # Buoyancy factor for underwater

# Health System
var max_health = 3
var current_health = 3
var damage_cooldown = 0.0
var damage_cooldown_time = 0.5  # 0.5 saniye hasar alma cooldown'u
var score = 0  # Skor sistemi

# Physics Variables
var current_tilt = 0.0
var target_tilt = 0.0
var tilt_timer = 0.0
var thrust_timer = 0.0
var hold_timer = 0.0
var is_thrusting = false
var last_input_direction = Vector2.ZERO
var momentum = Vector2.ZERO
var velocity_target = Vector2.ZERO
var is_underwater = false
var wall_collision_timer = 0.0
var last_wall_normal = Vector2.ZERO
var surface_normal = Vector2.ZERO
var velocity_history = []
var acceleration = Vector2.ZERO
var previous_velocity = Vector2.ZERO

@onready var sprite: Node2D = $Sprite2D if has_node("Sprite2D") else null
@onready var heart_display = $HeartDisplay
@onready var death_screen = get_node("/root/DeathScreen") if has_node("/root/DeathScreen") else null

func _ready():
	# Initialize velocity history for smooth movement
	for i in range(5):
		velocity_history.append(Vector2.ZERO)
	
	# Initialize health
	current_health = max_health

func _physics_process(delta: float) -> void:
	# Store previous velocity for acceleration calculation
	previous_velocity = velocity
	
	# Apply gravity
	var gravity_force = GRAVITY
	if is_underwater:
		gravity_force *= (1.0 - BUOYANCY)
	
	velocity.y += gravity_force * delta
	
	# Input handling
	var input_vector = _get_input_vector()
	
	# Handle momentum system
	_handle_momentum(input_vector, delta)
	
	# Handle thrust system (only for vertical movement)
	_handle_thrust_system(input_vector, delta)
	
	# Wall collision handling
	_handle_wall_collisions(delta)
	
	# Apply surface friction
	_apply_surface_friction(delta)
	
	# Update damage cooldown
	damage_cooldown -= delta
	
	# Velocity clamping and history
	_clamp_velocity()
	_update_velocity_history()
	
	# Smooth tilt animation
	_update_tilt_animation(delta)
	
	# Apply movement
	move_and_slide()
	
	# Calculate acceleration for effects
	acceleration = (velocity - previous_velocity) / delta

func _get_input_vector() -> Vector2:
	var left_pressed = Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A)
	var right_pressed = Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D)
	var up_pressed = Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W)
	var down_pressed = Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S)
	
	var move_direction = Vector2.ZERO
	
	# Simple directional logic
	if left_pressed and not right_pressed:
		if up_pressed and not down_pressed:
			move_direction = Vector2(-0.7, -0.3).normalized()
			target_tilt = -TILT_ANGLE * 0.7
		elif down_pressed and not up_pressed:
			move_direction = Vector2(-0.7, 0.3).normalized()
			target_tilt = -TILT_ANGLE * 0.7
		else:
			move_direction = Vector2(-1.0, 0.0)  # Pure horizontal left
			target_tilt = -TILT_ANGLE
			
	elif right_pressed and not left_pressed:
		if up_pressed and not down_pressed:
			move_direction = Vector2(0.7, -0.3).normalized()
			target_tilt = TILT_ANGLE * 0.7
		elif down_pressed and not up_pressed:
			move_direction = Vector2(0.7, 0.3).normalized()
			target_tilt = TILT_ANGLE * 0.7
		else:
			move_direction = Vector2(1.0, 0.0)  # Pure horizontal right
			target_tilt = TILT_ANGLE
			
	elif up_pressed and not down_pressed:
		move_direction = Vector2(0, -1)
		target_tilt = 0.0
		
	elif down_pressed and not up_pressed:
		move_direction = Vector2(0, 1)
		target_tilt = 0.0
		
	else:
		move_direction = Vector2.ZERO
		target_tilt = 0.0
	
	return move_direction

func _handle_momentum(input_vector: Vector2, delta: float) -> void:
	if input_vector != Vector2.ZERO:
		# Calculate target velocity
		velocity_target = input_vector * MOVE_SPEED
		
		# Balanced momentum interpolation
		var momentum_lerp_speed = 0.12
		if velocity.length() < MIN_VELOCITY:
			momentum_lerp_speed = 0.08
		
		momentum = momentum.lerp(velocity_target, momentum_lerp_speed)
		last_input_direction = input_vector
	else:
		# Gradual momentum decay
		momentum *= MOMENTUM_DECAY
		velocity_target = Vector2.ZERO
	
	# Apply resistance
	var resistance = AIR_RESISTANCE
	if is_underwater:
		resistance = WATER_RESISTANCE
	
	momentum *= resistance

func _handle_thrust_system(input_vector: Vector2, delta: float) -> void:
	# Use momentum for horizontal movement
	velocity.x = momentum.x
	
	# Apply thrust for any movement (both horizontal and vertical)
	if input_vector != Vector2.ZERO:
		if not is_thrusting:
			thrust_timer = THRUST_DELAY
			hold_timer = 0.0
			is_thrusting = true
		else:
			thrust_timer -= delta
			hold_timer += delta
			
			if thrust_timer <= 0:
				var power_ratio = min(hold_timer / THRUST_RAMP_TIME, 1.0)
				power_ratio = _ease_thrust_curve(power_ratio)
				
				var current_thrust = lerp(MIN_THRUST_FORCE, MAX_THRUST_FORCE, power_ratio)
				
				# Apply thrust to both horizontal and vertical movement
				if abs(input_vector.x) > 0.1:
					velocity.x += input_vector.x * current_thrust * 0.8 * delta
				if abs(input_vector.y) > 0.1:
					velocity.y += input_vector.y * current_thrust * 2.0 * delta  # Much stronger vertical thrust
	else:
		is_thrusting = false

func _ease_thrust_curve(t: float) -> float:
	# Smooth thrust curve
	return 1.0 - pow(1.0 - t, 2.0)

func _handle_wall_collisions(delta: float) -> void:
	wall_collision_timer -= delta
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		
		if wall_collision_timer <= 0:
			var bounce_velocity = velocity.bounce(normal)
			velocity = bounce_velocity * BOUNCE_FACTOR
			momentum = momentum.bounce(normal) * BOUNCE_FACTOR
			
			wall_collision_timer = 0.1
			last_wall_normal = normal
			surface_normal = normal
			
			# Take damage when hitting walls
			_take_damage_from_wall_collision()

func _apply_surface_friction(delta: float) -> void:
	if get_slide_collision_count() > 0:
		velocity *= FRICTION
		momentum *= FRICTION

func _clamp_velocity() -> void:
	if velocity.length() > MAX_VELOCITY:
		velocity = velocity.normalized() * MAX_VELOCITY
	
	if momentum.length() > MAX_VELOCITY:
		momentum = momentum.normalized() * MAX_VELOCITY
	
	if velocity.length() < MIN_VELOCITY and momentum.length() < MIN_VELOCITY:
		velocity *= 0.95
		momentum *= 0.95

func _update_velocity_history() -> void:
	velocity_history.push_back(velocity)
	velocity_history.pop_front()

func _update_tilt_animation(delta: float) -> void:
	if current_tilt != target_tilt:
		tilt_timer += delta
		var progress = tilt_timer / TILT_DURATION
		
		if progress >= 1.0:
			current_tilt = target_tilt
			tilt_timer = 0.0
		else:
			var eased_progress = _ease_tilt_curve(progress)
			current_tilt = lerp(current_tilt, target_tilt, eased_progress)
		
		_tilt_sprite(current_tilt)

func _ease_tilt_curve(t: float) -> float:
	return 1.0 - pow(1.0 - t, 2.0)

func _tilt_sprite(angle: float) -> void:
	if sprite:
		sprite.rotation_degrees = angle

# Public methods for external control
func set_underwater_state(underwater: bool) -> void:
	is_underwater = underwater

func get_velocity_magnitude() -> float:
	return velocity.length()

func get_momentum_magnitude() -> float:
	return momentum.length()

func get_acceleration_magnitude() -> float:
	return acceleration.length()

# Health and Damage Functions
func _take_damage_from_wall_collision() -> void:
	if damage_cooldown <= 0:
		var damage_amount = 1  # Her duvar çarpışmasında 1 kalp gider
		take_damage(damage_amount)
		damage_cooldown = damage_cooldown_time

func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(0, current_health)  # Can 0'ın altına düşmesin
	
	print("Hasar alındı! Kalan kalp: ", current_health)
	
	# Kalp gösterme sistemini güncelle
	if heart_display:
		heart_display.update_hearts()
	
	if current_health <= 0:
		_die()

func heal(amount: int) -> void:
	current_health += amount
	current_health = min(max_health, current_health)  # Can maksimumu geçmesin
	print("Can yenilendi! Yeni can: ", current_health)

func _die() -> void:
	print("Oyuncu öldü!")
	
	# Ölüm ekranını göster
	if death_screen:
		death_screen.show_death_screen(score)
	else:
		# Eğer ölüm ekranı yoksa direkt restart
		get_tree().reload_current_scene()

func get_health_percentage() -> float:
	return float(current_health) / float(max_health)

func add_score(points: int) -> void:
	score += points
	print("Skor: ", score)

func get_score() -> int:
	return score

# Enhanced collision response
func _on_body_entered(body: Node2D) -> void:
	pass

func _on_body_exited(body: Node2D) -> void:
	pass
