extends Area2D
class_name Bullet

@onready var sprite_2d = $Sprite2D

@export var speed: float = 1500
var direction: Vector2 = Vector2(1, 0)
var randomize = false
@onready var audio_stream_player = $AudioStreamPlayer
@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	body_entered.connect(on_body_entered)
	if randomize:
		randomize_sprite()


func _physics_process(delta):
	move(delta)


func on_body_entered(body: Node2D):
	if body is Enemy:
		print("enemy!!")
		on_enemy_hit(body as Enemy)
	else:
		print(str(body))
		on_wall_hit()
	

func on_wall_hit():
	audio_stream_player.play(0.0)
	sprite_2d.visible = false
	collision_shape_2d.set_deferred("disabled", true)
	await audio_stream_player.finished
	queue_free()


func on_enemy_hit(enemy: Enemy):
	enemy.hit_by_bullet()
	audio_stream_player.play(0.0)
	sprite_2d.visible = false
	collision_shape_2d.set_deferred("disabled", true)
	await audio_stream_player.finished
	queue_free()


func move(delta: float):
	position += direction * speed * delta

func randomize_sprite():
	sprite_2d.frame = randi_range(0,1)
