extends Node
class_name DeathDialogScene
@onready var dialog_box = $DialogBox as DialogBox
@onready var scene_changer_component = $SceneChangerComponent as SceneChangerComponent

func _ready():
	dialog_box.dialog_end.connect(on_dialog_end)
	scene_changer_component.next_scene = GameEvents.last_death_scene


func on_dialog_end():
	scene_changer_component.change_scene(true)
