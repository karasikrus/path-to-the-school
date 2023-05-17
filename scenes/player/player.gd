extends CharacterBody2D
class_name Player

signal shot_made

var bullet_scene = preload("res://scenes/bullet/bullet.tscn")
var bullet_cake_scene = preload("res://scenes/bullet/bullet_cake.tscn")
@onready var gun_point = $GunPoint
@onready var sprite_2d = $Sprite2D
@onready var foot_steps = $foot_steps
@onready var landing = $landing

@export var mail = false
@export var unicorn = false
@export var is_shooting_ducks = true
@export var can_shoot = false
@export var recoil_power: float = 400
# BASIC MOVEMENT VARAIABLES ---------------- #
var face_direction := 1
var x_dir := 1

@export var max_speed: float = 560
@export var acceleration: float = 2880
@export var turning_acceleration : float = 9600
@export var deceleration: float = 3400
# ------------------------------------------ #

# GRAVITY ----- #
@export var gravity_acceleration : float = 3840
@export var gravity_max : float = 1020

# Wall slide and jump
@export var wall_slide_gravity_acceleration: float = 3840
@export var wall_slide_gravity_max: float = 300
@export var wall_jump_horizontal_force: float = 600

@export var after_wall_jump_acceleration: float = 0
var is_wall_sliding: bool = false
var last_wall_is_to_the_left = false
var last_wall_is_to_the_right = false
var is_next_to_wall = false
# ------------- #

# JUMP VARAIABLES ------------------- #
@export var jump_force : float = 1100
@export var jump_cut : float = 0.25
@export var jump_gravity_max : float = 500
@export var jump_hang_treshold : float = 2.0
@export var jump_hang_gravity_mult : float = 0.1
# Timers
@export var jump_coyote : float = 0.3
@export var jump_buffer : float = 0.1
@export var wall_jump_coyote : float = 0.3
@export var shoot_interval : float = 0.5

var jump_coyote_timer : float = 0
var jump_buffer_timer : float = 0
var wall_jump_coyote_timer : float = 0
var is_jumping := false
var after_wall_jump_time : float = 0.7
var after_wall_jump_timer : float = 0
var shoot_interval_timer : float = 0
# ----------------------------------- #

@onready var animation_player = $AnimationPlayer
@onready var ray_cast_front = $RayCastFront as RayCast2D
@onready var ray_cast_back = $RayCastBack as RayCast2D
@onready var hurtbox_component = $HurtboxComponent as HurtboxComponent

var is_dead := false
@export var is_wind_active := false
@export var wind_power: float = 500.0


func _ready():
	hurtbox_component.damage.connect(on_damage)


# All iputs we want to keep track of
func get_input() -> Dictionary:
	return {
		"x": int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
		"just_jump": Input.is_action_just_pressed("jump") == true,
		"jump": Input.is_action_pressed("jump") == true,
		"released_jump": Input.is_action_just_released("jump") == true,
		"shoot": Input.is_action_pressed("shoot") == true
	}


func _physics_process(delta: float) -> void:
	if(!is_dead):
		if !unicorn:
			next_to_wall_logic()
			
		x_movement(delta)
		
		if !unicorn:
			wall_logic(delta)
			
		jump_logic(delta)
		apply_gravity(delta)
		shoot_logic()
		
		wind(delta)
		
		timers(delta)
		move_and_slide()
		landing_check()
		animate()
		
	mail_logic()
	


func lerp_after_wall_acceleration(target_acceleration: float) -> float:
	if after_wall_jump_timer <= 0:
		return target_acceleration
		
	var lerp_state := 1 - after_wall_jump_timer / after_wall_jump_time
	var wall_jump_current_accelerion := (lerp(after_wall_jump_acceleration, target_acceleration, lerp_state) as float)
	return wall_jump_current_accelerion


func x_movement(delta: float) -> void:
	x_dir = get_input()["x"]
	
	# Stop if we're not doing movement inputs.
	if x_dir == 0: 
		velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(0,0), lerp_after_wall_acceleration(deceleration) * delta).x
		return
	
	# If we are doing movement inputs and above max speed, don't accelerate nor decelerate
	# Except if we are turning
	# (This keeps our momentum gained from outside or slopes)
	if abs(velocity.x) >= max_speed and sign(velocity.x) == x_dir:
		set_direction(x_dir)
		return
	
	# Are we turning?
	# Deciding between acceleration and turn_acceleration
	
	var accel_rate : float = lerp_after_wall_acceleration(acceleration) if sign(velocity.x) == x_dir\
	else lerp_after_wall_acceleration(turning_acceleration)
	
	# Accelerate
	velocity.x += x_dir * accel_rate * delta
	set_direction(x_dir) # This is purely for visuals


func set_direction(hor_direction) -> void:
	# This is purely for visuals
	# Turning relies on the scale of the player
	# To animate, only scale the sprite
	if hor_direction == 0:
		return
	apply_scale(Vector2(hor_direction * face_direction, 1)) # flip
	face_direction = hor_direction # remember direction


func jump_vertically():
	foot_steps.play(0.0)
	is_jumping = true
	jump_coyote_timer = 0
	jump_buffer_timer = 0
	# If falling, account for that lost speed
	if velocity.y > 0:
		velocity.y -= velocity.y
	
	velocity.y = -jump_force

func jump_logic(_delta: float) -> void:
	# Reset our jump requirements
	if is_on_floor():
		jump_coyote_timer = jump_coyote
		is_jumping = false
	if is_wall_sliding:
		is_jumping = false
	if get_input()["just_jump"]:
		jump_buffer_timer = jump_buffer
	
	# Jump if grounded, there is jump input, and we aren't jumping already
	if jump_coyote_timer > 0 and jump_buffer_timer > 0 and not is_jumping and not is_wall_sliding:
		jump_vertically()
	
	if jump_buffer_timer > 0 and !is_on_floor():
		if last_wall_is_to_the_right && wall_jump_coyote_timer > 0:
			#wall is on the right
			jump_vertically()
			wall_jump_coyote_timer = 0
			velocity.x = -wall_jump_horizontal_force
			after_wall_jump_timer = after_wall_jump_time
			set_direction(-1)
		elif last_wall_is_to_the_left && wall_jump_coyote_timer > 0:
			#wall is on the left
			jump_vertically()
			wall_jump_coyote_timer = 0
			velocity.x = wall_jump_horizontal_force
			after_wall_jump_timer = after_wall_jump_time
			set_direction(1)
	
	# We're not actually interested in checking if the player is holding the jump button
#	if get_input()["jump"]:pass
	
	# Cut the velocity if let go of jump. This means our jumpheight is varaiable
	# This should only happen when moving upwards, as doing this while falling would lead to
	# The ability to studder our player mid falling
	if get_input()["released_jump"] and velocity.y < 0:
		velocity.y -= (jump_cut * velocity.y)
	
	# This way we won't start slowly descending / floating once hit a ceiling
	# The value added to the treshold is arbritary,
	# But it solves a problem where jumping into 
	if is_on_ceiling(): velocity.y = jump_hang_treshold + 100.0


func next_to_wall_logic() -> void:
	if ray_cast_front.is_colliding() && face_direction == 1\
	|| ray_cast_back.is_colliding() && face_direction == -1:
		last_wall_is_to_the_right = true
		last_wall_is_to_the_left = false
		wall_jump_coyote_timer = wall_jump_coyote
		is_next_to_wall = true
		return
	if ray_cast_front.is_colliding() && face_direction == -1\
	|| ray_cast_back.is_colliding() && face_direction == 1:
		last_wall_is_to_the_left = true
		last_wall_is_to_the_right = false
		wall_jump_coyote_timer = wall_jump_coyote
		is_next_to_wall = true
		return
	is_next_to_wall = false



func wall_logic(_delta: float):
	if !is_on_floor() && is_next_to_wall:
		if abs(x_dir) > 0 && velocity.y >= 0:
			wall_jump_coyote_timer = wall_jump_coyote
			is_wall_sliding = true
			return
	is_wall_sliding = false


func apply_gravity(delta: float) -> void:
	var applied_gravity : float = 0
	
	# No gravity if we are grounded
	if is_on_floor():
		return
	
	
	if is_wall_sliding:
		if velocity.y < wall_slide_gravity_max:
			applied_gravity = wall_slide_gravity_acceleration * delta
		else:
			velocity.y = wall_slide_gravity_max
	else:
		# Normal gravity limit
		if velocity.y <= gravity_max:
			applied_gravity = gravity_acceleration * delta
	
	# If moving upwards while jumping, the limit is jump_gravity_max to achieve lower gravity
	if (is_jumping and velocity.y < 0) and velocity.y > jump_gravity_max:
		applied_gravity = 0
	
	# Lower the gravity at the peak of our jump (where velocity is the smallest)
	if is_jumping and abs(velocity.y) < jump_hang_treshold:
		applied_gravity *= jump_hang_gravity_mult
	velocity.y += applied_gravity


func timers(delta: float) -> void:
	# Using timer nodes here would mean unnececary functions and node calls
	# This way everything is contained in just 1 script with no node requirements
	jump_coyote_timer -= delta
	jump_buffer_timer -= delta
	wall_jump_coyote_timer -= delta
	after_wall_jump_timer -= delta
	shoot_interval_timer -= delta

func animate():
	if is_wall_sliding:
		sprite_2d.flip_h = true
		animation_player.play("slide")
		return
	sprite_2d.flip_h = unicorn
	
	if shoot_interval_timer >= 0:
		if is_shooting_ducks:
			animation_player.play("shoot_ducks")
		else:
			animation_player.play("shoot_bad")
		return
	
	if velocity.y < 0:
		animation_player.play("jump")
		return
	
	if  velocity.y > 0:
		animation_player.play("fall")
		return
	
	
	if abs(x_dir) > 0:
		animation_player.play("run")
	else:
		animation_player.play("default")


func death():
	is_dead = true
	animation_player.play("death")
	await animation_player.animation_finished
	GameEvents.emit_player_death()


func wind(delta: float):
	if is_wind_active:
		position.x += -wind_power * delta


func on_damage(deadly: bool):
	if deadly:
		death()
	else:
		death()


func shoot_logic():
	if !can_shoot:
		return
	var scene = bullet_scene
	if unicorn:
		scene = bullet_cake_scene	
	if shoot_interval_timer <= 0 && get_input()["shoot"] && !is_wall_sliding:
		shoot_interval_timer = shoot_interval
		
		var bullet_instance = scene.instantiate() as Bullet
		owner.add_child(bullet_instance)
		bullet_instance.position = position + \
			Vector2(gun_point.position.x * face_direction, gun_point.position.y)
		bullet_instance.direction = Vector2.RIGHT * face_direction
		if unicorn:
			bullet_instance.randomize_sprite()
		recoil()
		shot_made.emit()
	

func recoil():
	velocity += Vector2.UP * recoil_power
	velocity += Vector2.LEFT * face_direction * recoil_power * 2

var last_state_is_floor = true
func landing_check():
	var state = is_on_floor()
	if !last_state_is_floor && state:
		landing.play(0.0)
	last_state_is_floor = state

func mail_logic():
	if mail:
		var moving = velocity.length() > 0 && !is_dead
		($MailParticles as MailParticles).set_mails_emitting(moving)
