extends Node2D

@export_range(-5, 5, 0.01) var speed: float = 1 
@export_range(0, 1, 0.01) var start_position: float = 0

@onready var animation_player = $AnimationPlayer


func _ready():
	animation_player.speed_scale = speed
	animation_player.advance(start_position * 5 / speed)
	

