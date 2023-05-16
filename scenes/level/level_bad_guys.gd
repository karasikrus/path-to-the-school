extends Node2D

var dead_enemies = 0
@export var max_dead_enemies = 3
@onready var scene_changer_component = $SceneChangerComponent as SceneChangerComponent


func _ready():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		(enemy as Enemy).enemy_died.connect(on_enemy_death)


func on_enemy_death():
	dead_enemies += 1
	if dead_enemies >= max_dead_enemies:
		scene_changer_component.change_scene()
