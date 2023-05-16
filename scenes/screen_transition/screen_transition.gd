extends CanvasLayer

signal transition_finished

@onready var animation_player = $AnimationPlayer
@onready var color_rect = $ColorRect

@export var dissolve_texture: Texture2D : set = _set_dissolve_texture


func _set_dissolve_texture(texture):
	color_rect.material.set_shader_parameter("dissolve_pattern", texture)


func emit_transition_finished():
	transition_finished.emit()


func transition_in():
	animation_player.play("in")


func transition_out():
	animation_player.play("out")

func unpause_game():
	get_tree().paused = false
