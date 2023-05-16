extends Node
class_name SceneChangerComponent

@export var next_scene_path: String
@export var dissolve_texture: Texture2D

var next_scene: PackedScene
var current_scene: PackedScene


func _ready():
	get_current_scene()
	GameEvents.player_death.connect(change_scene_on_death)

func _process(delta):
	if Input.is_action_just_pressed("skip"):
		change_scene()


func change_scene(on_death: bool = false):
	get_tree().paused = true
	if dissolve_texture != null:
		ScreenTransition._set_dissolve_texture(dissolve_texture)
	ScreenTransition.transition_in()
	await ScreenTransition.transition_finished
	if !on_death:
		next_scene = ResourceLoader.load(next_scene_path, "PackedScene")
	get_tree().change_scene_to_packed(next_scene)
	await get_tree().tree_changed
	ScreenTransition.transition_out()

func change_scene_on_death():
	GameEvents.last_death_scene = current_scene
	print(str(GameEvents.last_death_scene))
	next_scene = GameEvents.death_dialog_scene
	change_scene(true)


func get_current_scene():
	var current_scene_path := owner.scene_file_path
	print(str(current_scene_path))
	var packed_scene = ResourceLoader.load(current_scene_path, "PackedScene")
	current_scene = packed_scene

