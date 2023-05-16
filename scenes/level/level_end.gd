extends Area2D
class_name LevelEnd

signal level_finished

var normal_behavior := true


func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(_body: Node2D):
	level_finished.emit()
	
	if normal_behavior:
		change_scene()

func change_scene():
	var change_scene_component = get_tree()\
	.get_first_node_in_group("scene_changer_component") as SceneChangerComponent
	if change_scene_component == null:
		return
	
	change_scene_component.change_scene()
