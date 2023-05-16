extends Control
class_name Background
@onready var animation_player = $AnimationPlayer

func quake(speed: float = 1.0):
	animation_player.speed_scale = speed
	animation_player.play("quake")
