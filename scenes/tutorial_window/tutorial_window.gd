extends Control
class_name TutorialWindow

func _ready():
	$Timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	$AnimationPlayer.play("default")
