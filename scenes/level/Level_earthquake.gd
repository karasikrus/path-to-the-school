extends Node2D

@onready var earthquake_timer = $EarthquakeTimer
@onready var player = $Player
@onready var background = $Background as Background
@onready var animation_player = $AnimationPlayer

@export var quake_animation_speed: float = 1.0


func _ready():
	earthquake_timer.timeout.connect(on_timeout)


func on_timeout():
	if player.is_on_floor():
		player.jump_vertically()
	
	background.quake(quake_animation_speed)
	animation_player.play("quake")
