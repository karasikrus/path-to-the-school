extends CharacterBody2D
class_name Enemy

signal enemy_died

@onready var ray_cast_front_forward = $RayCastFrontForward as RayCast2D
@onready var ray_cast_front_down = $RayCastFrontDown as RayCast2D
@onready var sprite_2d_bad_guy = $Sprite2D_bad_guy
@onready var sprite_2d_duck = $Sprite2D_duck
@onready var sprite_2d_dragon = $Sprite2D_dragon
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D


@export var speed = 100.0
@export var direction = 1

var gravity = 50
var is_dead = false

enum enemy_type {bad_guy, duck, dragon}
@export var current_enemy_type = enemy_type.bad_guy 


func _ready():
	set_sprite()


func _process(delta):
	if !is_dead:
		check_platform_end()
		move(delta)


func move(_delta: float):
	velocity.x = speed * direction
	velocity.y = gravity
	move_and_slide()


func change_direction():
	direction *= -1
	scale.x *= -1


func check_platform_end():
	if ray_cast_front_forward.is_colliding() || !ray_cast_front_down.is_colliding():
		change_direction()


func on_platform_end():
	change_direction()


func hit_by_bullet():
	is_dead = true
	collision_shape_2d.set_deferred("disabled", true)
	animation_player.play("death")
	await animation_player.animation_finished
	enemy_died.emit()
	queue_free()


func set_sprite():
	var sprite: Sprite2D = sprite_2d_bad_guy
	if current_enemy_type == enemy_type.duck:
		sprite = sprite_2d_duck
	elif current_enemy_type == enemy_type.dragon:
		sprite = sprite_2d_dragon
	
	sprite_2d.texture = sprite.texture
	sprite_2d.scale = sprite.scale
	sprite_2d.flip_h = sprite.flip_h
	
