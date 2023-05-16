extends Node
class_name DialogScene

@onready var dialog_box = $DialogBox as DialogBox
@onready var scene_changer_component = $SceneChangerComponent as SceneChangerComponent


func _ready():
	dialog_box.dialog_end.connect(on_dialog_end)


func on_dialog_end():
	scene_changer_component.change_scene()
