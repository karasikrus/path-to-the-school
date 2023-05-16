extends Node

var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()
