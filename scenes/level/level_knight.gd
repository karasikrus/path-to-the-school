extends Node2D

@onready var audio_stream_player = $AudioStreamPlayer

func _ready():
	audio_stream_player.play(1.55)
