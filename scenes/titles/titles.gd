extends CanvasLayer

@onready var button = %Button
@onready var scene_changer_component = $SceneChangerComponent as SceneChangerComponent


func _ready():
	button.pressed.connect(on_button_pressed)

func on_button_pressed():
	scene_changer_component.change_scene()
