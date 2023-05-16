extends Node

@onready var timer = $Timer
@onready var scene_changer_component = $SceneChangerComponent as SceneChangerComponent

func _ready():
	timer.timeout.connect(end)

func end():
	scene_changer_component.change_scene()
