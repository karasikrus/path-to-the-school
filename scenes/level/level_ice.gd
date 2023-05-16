extends Node2D

@onready var player = $Player as Player
@export var decceleration = 1000
@export var turning_decceleration = 1000
@export var acceleration = 1000

var start_decceleration
var start_turning_acceleration
var start_acceleration

func _ready():
	start_decceleration = player.deceleration
	start_turning_acceleration = player.turning_acceleration
	start_acceleration = player.acceleration


func _physics_process(delta):
	if player.is_on_floor():
		player.deceleration = decceleration
		player.turning_acceleration = turning_decceleration
		player.acceleration = acceleration
	else:
		player.deceleration = start_decceleration/4
		player.turning_acceleration = start_turning_acceleration/2
		player.acceleration = start_acceleration/4
