extends Node2D

@onready var player = $Player as Player
@onready var wind_duration_timer = $WindDurationTimer
@onready var wind_interval_timer = $WindIntervalTimer
@onready var wind_particles = $WindParticles
@onready var audio_stream_player = $AudioStreamPlayer

@export var wind_power: float = 1000


func _ready():
	wind_duration_timer.timeout.connect(on_wind_end)
	wind_interval_timer.timeout.connect(on_interval_end)


func on_interval_end():
	appear_wind()
	player.wind_power = wind_power
	player.is_wind_active = true
	wind_duration_timer.start()
	print("wind started")


func on_wind_end():
	disappear_wind()
	player.is_wind_active = false
	wind_interval_timer.start()
	print("interval started")

func appear_wind():
	audio_stream_player.play(0.0)
	var tween = create_tween()
	tween.tween_property(wind_particles, "modulate", Color(1, 1, 1, 0), 0)
	tween.tween_property(wind_particles, "modulate", Color(1, 1, 1, 1), .3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

func disappear_wind():
	var tween = create_tween()
	tween.tween_property(wind_particles, "modulate", Color(1, 1, 1, 1), 0)
	tween.tween_property(wind_particles, "modulate", Color(1, 1, 1, 0), .3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
